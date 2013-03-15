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

      def remaining_opponents
        opponents - trick.players
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
        suits = valid_card_suits_counts
        if suits.count > 1 && suits.has_key?(round.trump_suit)
          suits.delete(round.trump_suit)
          suit, cards = suits.min do |a, b| a[1].count <=> b[1].count end
          cards.last
        else # just the lowest valid card
          round.valid_cards.last
        end
      end

      def highest_card
        round.valid_cards.first
      end

      def lowest_winner
        max_played_card = trick.ranked_cards.first
        my_higher_cards = round.valid_cards.select {|c| c.rank(round.trump_suit, round.led_suit) > max_played_card.rank(round.trump_suit, round.led_suit) }

        my_higher_cards.last
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
        my_valid_cards = round.valid_cards
        my_top_card = my_valid_cards.first
        remaining = round.remaining_cards_plus_current_trick
        partner_played_ix = remaining.index(partner_played)
        my_top_card_ix = remaining.index(my_top_card)

        min_range = [partner_played_ix, my_top_card_ix].min
        max_range = [partner_played_ix, my_top_card_ix].max

        in_range = remaining[min_range..max_range]
        opponent_card_in_range = in_range - my_valid_cards - [partner_played]

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
        max_rank = trick.ranked_cards.first.rank(round.trump_suit, round.led_suit) || 0

        round.valid_cards.first.rank(round.trump_suit, round.led_suit) > max_rank
      end

      def can_use_trump?
        round.valid_cards.first.suit(round.trump_suit) == round.trump_suit
      end

      def partner_winning_trick?
        partner == trick.ranked_players.first
      end
    end
  end
end
