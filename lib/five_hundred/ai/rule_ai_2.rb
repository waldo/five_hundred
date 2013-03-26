# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RuleAI2 < RuleAI
      def request_bid
        if @max_bid.nil?
          bid_number = max_cards_for_any_suit + 3
          bid_number += 1 if @cards.include? Deck.card("Jo")
          bid_number = [10, bid_number].min
          @max_bid = Bid.create_with_tricks_and_suit(bid_number, suit_with_most_cards)
        end

        stepped_bid(@max_bid)
      end

      def stepped_bid(max_bid)
        max_req = max_bid.tricks_required
        min_req = [6, max_req - 2].max
        range = min_req..max_req
        range.each do |tricks_req|
          my_bid = Bid.create_with_tricks_and_suit(tricks_req, max_bid.suit)
          return my_bid if my_bid > round.highest_bid
        end

        Bid.new("pass")
      end
    end
  end
end
