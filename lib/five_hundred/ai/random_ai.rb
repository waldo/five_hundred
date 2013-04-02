# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RandomAI < GeneralAI
      def request_bid
        [round.valid_bids.sample, Bid.pass].sample
      end

      def request_kitty
        (@cards + @kitty).sample(3)
      end

      def request_play
        round.valid_cards.sample
      end
    end
  end
end
