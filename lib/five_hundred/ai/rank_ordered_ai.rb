# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RankOrderedAI < OrderedAI
      def request_kitty
        cards_to_discard = []

        suits_by_card_count.reverse.each do |suit, arr|
          if arr.length > 0 && suit != :none
            arr.sort_by {|c| c.rank(@r.trump_suit) }.slice(0...arr.length).each do |c|
              if cards_to_discard.length < 3
                cards_to_discard << c unless c.rank(@r.trump_suit) >= 14
                cards_to_discard << c if suit == @r.trump_suit # in case we have only trump suit cards left
              end
            end
          end
        end

        cards_to_discard
      end

      def to_s
        "#{self.class} 0.1"
      end
    end
  end
end
