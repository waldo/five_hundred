# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class HighLowAI < OrderedAI
      def request_play
        top_card = round.remaining_rank_ordered_cards.first
        # return highest ranked card (if you have it)
        if round.valid_cards.include?(top_card)
          return top_card
        end
        # return lowest ranked card
        round.valid_cards.sort_by{|c| c.rank(round.trump_suit) }.first
      end

      def to_s
        "#{self.class} 0.1"
      end
    end
  end
end
