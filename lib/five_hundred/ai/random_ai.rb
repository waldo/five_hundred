# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RandomAI < Player
      def request(type, g)
        self.send("request_#{type}", g)
      end

      def request_bid(g)
        [g.current_round.valid_bids.sample, Bid.new("pass")][rand(2)]
      end

      def request_kitty(g)
        starting_ix = rand(10)
        (@cards + @kitty).slice(starting_ix..(starting_ix + 2))
      end

      def request_play(g)
        g.current_round.valid_cards.sample
      end

      def to_s
        "#{self.class} 0.2"
      end
    end
  end
end
