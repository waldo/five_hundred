# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class HighLowAI < GeneralAI
      def request_play
        top_card = round.remaining_cards.first
        # return highest ranked card (if you have it)
        if round.valid_cards.include?(top_card)
          return top_card
        end
        # return lowest ranked card
        round.valid_cards.last
      end
    end
  end
end
