# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RuleAI < GeneralAI
      def request_play
        return highest_card if one_valid_choice?
        return position_dependant_rules if winnable_trick?

        return lowest_card
      end

      def position_dependant_rules
        position_symbols = {0 => :first, 1 => :second, 2 => :third, 3 => :fourth}
        position = trick.cards.count

        send("playing_#{position_symbols[position]}")
      end

      def playing_first
        return highest_card if guaranteed_winner?

        return non_trump_expected_winner || lowest_card
      end

      def playing_second
        return highest_card if trump_suit_led?
        return lowest_trump if can_use_trump? && opponents_short_trumps_or_have_suit?(round.led_suit)

        return highest_card
      end

      def playing_third
        return lowest_card if partner_played_guaranteed_winner? || top_card_equivalent_to_partners_card?

        return playing_second
      end

      def playing_fourth
        return lowest_card if partner_winning_trick?

        return lowest_winner
      end

      def non_trump_expected_winner
        top_cards_non_trump_suit.each do |card|
          return card if opponents_short_trumps_or_have_suit?(card.suit(round.trump_suit))
        end

        nil
      end

      def opponents_short_trumps_or_have_suit?(suit)
        remaining_opponents.all? do |opponent|
          guess_player_has_suit?(opponent, suit) || !guess_player_has_suit?(opponent, round.trump_suit)
        end
      end

      # actions
      def lowest_card
        return round.valid_cards.last if no_trumps_or_only_trumps?

        suits_hash = valid_card_suits_counts
        suits_hash.delete(round.trump_suit)
        _suit, cards = suits_hash.min {|a, b| a[1].count <=> b[1].count }
        return cards.last
      end

      def highest_card
        round.valid_cards.first
      end

      def lowest_winner
        max_rank = trick.max_rank
        round.valid_cards.select {|c| c.rank(round.trump_suit, round.led_suit) > max_rank }.last
      end

      def lowest_trump
        valid_card_suits_counts[round.trump_suit].last
      end

      def valid_card_suits_counts
        suits = Hash.new {|h, k| h[k] = [] }

        round.valid_cards.each do |c|
          suits[c.suit(round.trump_suit)] << c
        end

        suits
      end

      def one_valid_choice?
        round.valid_cards.count == 1
      end

      def guaranteed_winner?
        top_card = round.remaining_cards_plus_current_trick.first
        valid_cards = round.valid_cards

        valid_cards.include?(top_card)
      end

      def partner_played_guaranteed_winner?
        top_card = (round.remaining_cards_plus_current_trick - cards).first
        partner_played = trick.card_played_by(self.partner)

        top_card == partner_played
      end

      def top_card_equivalent_to_partners_card?
        partner_played = trick.card_played_by(self.partner)
        remaining = round.remaining_cards_plus_current_trick
        partner_played_ix = remaining.index(partner_played)
        highest_card_ix = remaining.index(highest_card)

        min_ix = [partner_played_ix, highest_card_ix].min
        max_ix = [partner_played_ix, highest_card_ix].max

        in_range = remaining[min_ix..max_ix]
        opponent_card_in_range = in_range - round.valid_cards - [partner_played]

        opponent_card_in_range.length == 0
      end

      def top_cards_non_trump_suit
        suits = [:spades, :clubs, :diamonds, :hearts] - Array(round.trump_suit)
        top_cards = []

        suits.each do |s|
          remaining_cards = round.remaining_cards(s)
          top_cards << remaining_cards.first if remaining_cards && round.valid_cards.include?(remaining_cards.first)
        end

        top_cards
      end

      def guess_player_has_suit?(player, suit)
        !round.voided_suits(player).include?(suit) && (round.remaining_cards(suit) - cards).count >= 3
      end

      def trump_suit_led?
        round.trump_suit == round.led_suit
      end

      def winnable_trick?
        highest_card.rank(round.trump_suit, round.led_suit) > trick.max_rank
      end

      def can_use_trump?
        highest_card.suit(round.trump_suit) == round.trump_suit
      end

      def partner_winning_trick?
        partner == trick.ranked_players.first
      end

      def no_trumps_or_only_trumps?
        !has_trumps?(round.trump_suit) || suits(round.trump_suit).count == 1
      end
    end
  end
end
