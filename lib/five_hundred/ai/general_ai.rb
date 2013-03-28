# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class GeneralAI < Player
      def request(type)
        self.send("request_#{type}")
      end

      def request_bid
        bid_suit_letter = suit_with_most_cards.to_s[0]
        bid_number = max_cards_for_any_suit + 3
        bid_number += 1 if @cards.include? Deck.card("Jo")
        bid_number = [10, bid_number].min
        my_bid = Bid.new("#{bid_number.to_s}#{bid_suit_letter}")
        return my_bid if my_bid > round.highest_bid
        return Bid.new("pass")
      end

      def request_kitty
        (@cards + @kitty).sort_by {|c| c.rank[round.trump_suit][nil] }.slice(0..2)
      end

      def request_play
        round.valid_cards.first
      end

      def cards_by_suit
        suits_hash = { spades: [], clubs: [], diamonds: [], hearts: [] }

        @cards.map do |c|
          suits_hash.each do |s, _|
            suits_hash[c.suit[s]] << c if c.suit[s] == s
          end
        end

        suits_hash.sort_by {|key, arr| -arr.count }
      end

      def suit_with_most_cards
        cards_by_suit.first[0]
      end

      def max_cards_for_any_suit
        cards_by_suit.first[1].count
      end

      def to_s
        "#{self.class}"
      end

      def valid_cards_by_suit
        suits = Hash.new {|h, k| h[k] = [] }

        round.valid_cards.each do |c|
          suits[c.suit[round.trump_suit]] << c
        end

        suits
      end
      private :valid_cards_by_suit

      def no_trumps_or_only_one_valid_suit?
        !has_trumps?(round.trump_suit) || valid_cards_by_suit.count == 1
      end
      private :no_trumps_or_only_one_valid_suit?

      # actions
      def lowest_card
        return round.valid_cards.last if no_trumps_or_only_one_valid_suit?

        suits_hash = valid_cards_by_suit
        suits_hash.delete(round.trump_suit)
        _suit, cards = suits_hash.min {|a, b| a[1].count <=> b[1].count }
        return cards.last
      end

      def highest_card
        round.valid_cards.first
      end

      def lowest_winner
        max_rank = trick.max_rank
        round.valid_cards.select {|c| c.rank[round.trump_suit][trick.led_suit] > max_rank }.last
      end

      def lowest_trump
        valid_cards_by_suit[round.trump_suit].last
      end
    end
  end
end
