# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class ProbabilityAI < OrderedAI
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

      def probabilities
        slots = (0..3).to_a << :kitty
        codes = Deck.set_of_cards.map(&:code)
        probability_list = Hash.new {|h, k| h[k] = {} }

        slots.each do |slot|
          codes.each do |code|
            probability_list[slot][code] = 10 / 43.0
            probability_list[slot][code] = 3 / 43.0 if slot == :kitty
          end
        end

        probability_list
      end
    end
  end
end
