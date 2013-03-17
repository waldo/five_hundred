# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class GeneralAI < Player
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
        (@cards + @kitty).sort_by {|c| c.rank(round.trump_suit) }.slice(0..2)
      end

      def request_play
        round.valid_cards.first
      end

      def suits_by_card_count
        suits = Hash.new {|h, k| h[k] = [] }

        @cards.map do |c|
          suits[c.suit] << c
        end

        suits.sort_by {|key, arr| -arr.count }
      end

      def suit_with_most_cards
        suits_by_card_count.first[0]
      end

      def max_cards_for_any_suit
        suits_by_card_count.first[1].count
      end

      def to_s
        "#{self.class}"
      end

      def valid_card_suits_counts
        suits = Hash.new {|h, k| h[k] = [] }

        round.valid_cards.each do |c|
          suits[c.suit(round.trump_suit)] << c
        end

        suits
      end

      def no_trumps_or_only_trumps?
        !has_trumps?(round.trump_suit) || valid_card_suits_counts.count == 1
      end

      # actions
      def lowest_card
        return round.valid_cards.last if no_trumps_or_only_trumps?

        suits_hash = valid_card_suits_counts
        suits_hash.delete(round.trump_suit)
        _suit, cards = suits_hash.min {|a, b| a[1].count <=> b[1].count }
        return cards.last
      end

      def highest_card
        round.valid_cards.first
      end

      def lowest_winner
        max_rank = trick.max_rank
        round.valid_cards.select {|c| c.rank(round.trump_suit, round.led_suit) > max_rank }.last
      end

      def lowest_trump
        valid_card_suits_counts[round.trump_suit].last
      end
    end
  end
end
