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
            if self.cards.map(&:code).include?(code)
              if slot == @g.players.index(self)
                probability_list[slot][code] = 1.0
              else
                probability_list[slot][code] = 0.0
              end
            else
              if slot == @g.players.index(self)
                probability_list[slot][code] = 0.0
              elsif slot == :kitty
                probability_list[slot][code] = 3 / 33.0
              else
                probability_list[slot][code] = 10 / 33.0
              end
            end
          end
        end

        probability_list
      end
    end
  end
end
