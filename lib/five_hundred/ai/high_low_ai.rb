# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class HighLowAI < OrderedAI
      def request_play
        top_card = @r.remaining_rank_ordered_cards.first
        # return highest ranked card (if you have it)
        if @r.valid_cards.include?(top_card)
          return top_card
        end
        # return lowest ranked card
        @r.valid_cards.sort_by{|c| c.rank(@r.trump_suit) }.first
      end

      def to_s
        "#{self.class} 0.1"
      end
    end
  end
end
