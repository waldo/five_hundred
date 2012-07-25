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
        known_cards = (cards + kitty).count.to_f
        probability_list = Hash.new {|h, k| h[k] = {} }

        slots.each do |slot|
          codes.each do |code|
            if (cards + kitty).map(&:code).include?(code)
              if slot == @g.players.index(self)
                probability_list[slot][code] = 1.0
              else
                probability_list[slot][code] = 0.0
              end
            else
              if slot == @g.players.index(self)
                probability_list[slot][code] = 0.0
              elsif slot == :kitty
                probability_list[slot][code] = 3.0 / (43.0 - known_cards)
                probability_list[slot][code] = 0.0 if @r.winning_bidder == self
              else
                probability_list[slot][code] = 10.0 / (43.0 - known_cards)
              end
            end
          end
        end

        probability_list
      end
    end
  end
end
