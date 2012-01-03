# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RandomAI < Player
      def request(type, g)
        self.send("request_#{type}", g)
      end

      def request_bid(g)
        bid_code = [Bid.all.keys[rand(Bid.all.count)], "pass"][rand(2)]
        Bid.new(bid_code)
      end

      def request_kitty(g)
        starting_ix = rand(10)
        @cards.slice(starting_ix..(starting_ix + 2))
      end

      def request_play(g)
        @cards[rand(@cards.count)]
      end

      def to_s
        "RandomAI v0"
      end
    end
  end
end