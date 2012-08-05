# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RuleAI < Player
      def request(type, g)
        @g = g
        @r = g.current_round
        @t = g.current_round.trick_set.current_trick
        self.send("request_#{type}")
      end

      def request_bid
        bid_suit_letter = suit_with_most_cards.to_s[0]
        bid_number = max_cards_for_any_suit + 3
        bid_number += 1 if @cards.include? Deck.card("Jo")
        bid_number = [10, bid_number].min
        my_bid = Bid.new("#{bid_number.to_s}#{bid_suit_letter}")
        return my_bid if my_bid > @r.highest_bid
        return Bid.new("pass")
      end

      def request_kitty
        (@cards + @kitty).sort_by {|c| c.rank(@r.trump_suit) }.slice(0..2)
      end

      def request_play
        @r.valid_cards.sort_by{|c| -c.rank(@r.trump_suit) }.first
      end

      def one_valid_choice?(cards=@r.valid_cards)
        cards.count == 1
      end

      def guaranteed_winner?(cards=@r.valid_cards, top_card=@r.remaining_rank_ordered_cards.first)
        cards.include?(top_card)
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
