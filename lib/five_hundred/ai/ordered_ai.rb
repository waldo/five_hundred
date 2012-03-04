# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class OrderedAI < Player
      def request(type, g)
        @g = g
        @r = g.current_round
        @t = g.current_round.trick_set.current_trick
        self.send("request_#{type}")
      end

      def request_bid
        bid_suit_letter = suits_by_card_count.first[0].to_s[0]
        bid_number = suits_by_card_count.first[1] + 3
        bid_number += 1 if @cards.include? Deck.card("Jo")
        bid_number = [10, bid_number].min
        my_bid = Bid.new("#{bid_number.to_s}#{bid_suit_letter}")
        return my_bid if my_bid > @r.highest_bid
        return Bid.new("pass")
      end

      def request_kitty
        @cards.sort_by {|c| c.rank(@r.trump_suit)}.slice(0..2)
      end

      def request_play
        cards = @cards.sort_by {|c| -c.rank(@r.trump_suit)}

        if [:misere, :none].include?(@r.trump_suit)
          most_of = suits_by_card_count.detect { |suit, count| suit != :none }.first
          cards.first.set_joker_suit(most_of)
          cards.first.set_joker_suit(@t.led_suit) unless leading_and_is_joker?(cards.first)
        end

        cards.each do |c|
          return c if @t.valid_play?(c, self)
        end
        cards.first
      end

      def suits_by_card_count
        suits = {:spades => 0, :clubs => 0, :diamonds => 0, :hearts => 0, :none => 0}
        @cards.map do |c|
          suits[c.suit] += 1
        end
        suits.sort_by {|key, value| -value}
      end

      def leading_and_is_joker?(c)
        @t.cards.count == 0 and @r.joker_rules_ok?(c)
      end

      def to_s
        "OrderedAI v0.1"
      end
    end
  end
end
