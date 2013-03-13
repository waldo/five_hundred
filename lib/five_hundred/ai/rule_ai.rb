# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RuleAI < Player
      def request_bid
        bid_suit_letter = suit_with_most_cards.to_s[0]
        bid_number = max_cards_for_any_suit + 3
        bid_number += 1 if @cards.include? Deck.card("Jo")
        bid_number = [10, bid_number].min
        my_bid = Bid.new("#{bid_number.to_s}#{bid_suit_letter}")
        return my_bid if my_bid > round.highest_bid
        return Bid.new("pass")
      end

      def request_kitty
        (@cards + @kitty).sort_by {|c| c.rank(round.trump_suit) }.slice(0..2)
      end

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
          # playing_last
          play_low
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
        playing_common_second_or_third
      end

      def playing_third
        # initial strategy if playing third
        playing_common_second_or_third
      end

      def playing_common_second_or_third
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
            if partner_played_top_in_led_suit_excluding_my_cards?
              play_low
            else
              play_highest
            end
          end
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
        top_card = round.remaining_cards_plus_current_trick.first
        partner_played = round.card_played_by(self.partner)

        top_card == partner_played
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

      def partner_played_top_in_led_suit_excluding_my_cards?
        partner_card = round.card_played_by(self.partner)
        return false if partner_card.nil?

        (round.remaining_cards(round.led_suit) - cards).all? do |c|
          c.rank_with_led(round.led_suit, round.trump_suit) <= partner_card.rank_with_led(round.led_suit, round.trump_suit)
        end
      end

      def suits_by_card_count
        suits = Hash.new {|h, k| h[k] = [] }

        @cards.map do |c|
          suits[c.suit] << c
        end

        suits.sort_by {|key, arr| -arr.count }
      end

      def suit_with_most_cards
        suits_by_card_count.first[0]
      end

      def max_cards_for_any_suit
        suits_by_card_count.first[1].count
      end

      def to_s
        "#{self.class} 0.1"
      end
    end
  end
end
