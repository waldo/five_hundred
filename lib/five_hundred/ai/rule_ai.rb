# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RuleAI < GeneralAI
      def request_play
        if one_valid_choice?
          round.valid_cards.first
        elsif winnable_trick?
          position_dependant_rules
        else
          play_low
        end
      end

      def position_dependant_rules
        position = round.current_trick.cards.count

        case position
        when 0
          playing_first
        when 1
          playing_second
        when 2
          playing_third
        when 3
          playing_fourth
        end
      end

      def playing_first
        if guaranteed_winner?
          play_highest
        else
          non_trump_expected_winner || play_low
        end
      end

      def playing_second
        if trump_suit_led?
          play_highest
        else
          if can_use_trump?
            if all_opponents_have_suit_or_short_trumps?(round.led_suit)
              trump_low
            else
              trump_high
            end
          else
            play_highest
          end
        end
      end

      def playing_third
        if partner_played_guaranteed_winner? || top_card_equivalent_to_partners_card?
          play_low
        else
          playing_second
        end
      end

      def playing_fourth
        if partner_winning_trick?
          play_low
        else
          play_lowest_winner
        end
      end

      def remaining_opponents
        opponents - round.current_trick.players
      end

      def non_trump_expected_winner
        top_cards_non_trump_suit.each do |card|
          return card if all_opponents_have_suit_or_short_trumps?(card.suit(round.trump_suit))
        end

        nil
      end

      def all_opponents_have_suit_or_short_trumps?(suit)
        remaining_opponents.all? do |opponent|
          guess_player_has_suit?(opponent, suit) || !guess_player_has_suit?(opponent, round.trump_suit)
        end
      end

      def play_low
        suits = valid_card_suits_counts
        if suits.count > 1 && suits.has_key?(round.trump_suit)
          suits.delete(round.trump_suit)
          suit, cards = suits.min do |a, b| a[1].count <=> b[1].count end
          cards.last
        else # just the lowest valid card
          round.valid_cards.sort_by{|c| c.rank(round.trump_suit) }.first
        end
      end

      def play_highest
        round.valid_cards.first
      end

      def play_lowest_winner
        max_played_card = round.current_trick.cards.max_by {|c| c.rank_with_led(round.led_suit, round.trump_suit) }
        my_higher_cards = round.valid_cards.select {|c| c.rank_with_led(round.led_suit, round.trump_suit) > max_played_card.rank_with_led(round.led_suit, round.trump_suit) }
        my_higher_cards.min_by {|c| c.rank_with_led(round.led_suit, round.trump_suit) }
      end

      def trump_high
        valid_card_suits_counts[round.trump_suit].first
      end

      def trump_low
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
        partner_played = round.card_played_by(self.partner)

        top_card == partner_played
      end

      def top_card_equivalent_to_partners_card?
        partner_played = round.card_played_by(self.partner)
        my_valid_cards = round.valid_cards
        my_top_card = my_valid_cards.first
        remaining = round.remaining_cards_plus_current_trick
        partner_played_ix = remaining.index(partner_played)
        my_top_card_ix = remaining.index(my_top_card)

        min_range = [partner_played_ix, my_top_card_ix].min
        max_range = [partner_played_ix, my_top_card_ix].max

        remaining[min_range..max_range].all? do |card|
          my_valid_cards.include?(card) || partner_played == card
        end
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
        max_rank = round.current_trick.cards.map {|card| card.rank_with_led(round.led_suit, round.trump_suit)}.max || 0

        round.valid_cards.any? do |c|
          c.rank_with_led(round.led_suit, round.trump_suit) > max_rank
        end
      end

      def can_use_trump?
        round.valid_cards.any? do |c|
          c.suit(round.trump_suit) == round.trump_suit
        end
      end

      def partner_winning_trick?
        partner_card = round.card_played_by(self.partner)
        return false if partner_card.nil?

        round.current_trick.cards.all? do |c|
          c.rank_with_led(round.led_suit, round.trump_suit) <= partner_card.rank_with_led(round.led_suit, round.trump_suit)
        end
      end
    end
  end
end
