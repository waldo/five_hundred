# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RankOrderedAI < OrderedAI
      def request_bid
        bid_suit_letter = suits_by_rank_total.first[0].to_s[0]
        bid_number = suits_by_rank_total.first[1] / 6
        bid_number += 1 if @cards.include? Deck.card("Jo")
        bid_number = [10, bid_number].min
        bid_number = [6, bid_number].max
        my_bid = Bid.new("#{bid_number.to_s}#{bid_suit_letter}")
        return my_bid if my_bid > @r.highest_bid
        return Bid.new("pass")
      end

      def suits_by_rank_total
        suits = {:spades => 0, :clubs => 0, :diamonds => 0, :hearts => 0, :none => 0}
        @cards.map do |c|
          suits[c.suit] += c.rank unless c.joker?
        end

        suits.sort_by {|key, value| -value}
      end

      def to_s
        "#{self.class} 0.1"
      end
    end
  end
end
