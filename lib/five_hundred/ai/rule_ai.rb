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
        round.valid_cards.sort_by{|c| -c.rank(round.trump_suit) }.first
      end

      def one_valid_choice?
        round.valid_cards.count == 1
      end

      def guaranteed_winner?
        top_card = round.remaining_cards.first
        valid_cards = round.valid_cards

        valid_cards.include?(top_card)
      end

      def top_cards_non_trump_suit
        suits = [:spades, :clubs, :diamonds, :hearts] - Array(round.trump_suit)
        top_cards = []

        suits.each do |s|
          remaining_cards = round.remaining_cards(s)
          top_cards << remaining_cards.first if remaining_cards && cards.include?(remaining_cards.first)
        end

        top_cards
      end

      def guess_player_has_suit?(player, suit)
        !round.voided_suits(player).include?(suit) && (round.remaining_cards(suit) - cards).count > 3
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
