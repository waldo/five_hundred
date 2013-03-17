# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RuleAI < GeneralAI
      def request_play
        return highest_card if one_valid_choice?
        return position_rules if winnable_trick?

        return lowest_card
      end

      def position_rules
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

      def one_valid_choice?
        round.valid_cards.count == 1
      end

      def guaranteed_winner?
        top_card = round.remaining_cards_plus_current_trick.first

        top_card == round.valid_cards.first
      end

      def partner_played_guaranteed_winner?
        top_card = (round.remaining_cards_plus_current_trick - cards).first
        partner_played = trick.card_played_by(self.partner)

        top_card == partner_played
      end

      def top_card_equivalent_to_partners_card?
        partner_played = trick.card_played_by(self.partner)
        my_cards_except_top = round.valid_cards.drop(1)
        remaining = round.remaining_cards_plus_current_trick - my_cards_except_top

        remaining.index(partner_played) - remaining.index(highest_card) == 1
      end

      def top_cards_non_trump_suit
        suits = [:spades, :clubs, :diamonds, :hearts]
        suits.delete(round.trump_suit)

        top_cards = suits.map {|s| round.remaining_cards(s).first }

        top_cards.select {|card| round.valid_cards.include?(card) }
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
    end
  end
end
