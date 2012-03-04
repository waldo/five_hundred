# encoding: UTF-8

module FiveHundred
  module RoundSets
    class Bidding
      attr_reader :highest_bid

      def initialize(bidders)
        @bidders = bidders

        @highest_bid = Bid.new("empty")
        @bids = Hash.new{|h, k| h[k] = []}
        @bids[@highest_bid.to_s] << Player.empty
      end

      def bid(new_bid)
        bid!(new_bid) if valid_bid?(new_bid)
      end

      def bid!(new_bid)
        @bids[new_bid.to_s] << current_bidder
        if new_bid.passed?
          @bidders.shift
        else
          @highest_bid = new_bid
          next_bidder!
        end
      end
      private :bid!

      def valid_bid?(new_bid)
        return false if new_bid.nil? || complete? || everyone_passed?
        new_bid > @highest_bid
      end

      def complete?
        (passed_count == 3 && !@highest_bid.empty?) || @highest_bid.max_bid?
      end

      def current_bidder
        @bidders.first
      end

      def next_bidder
        @bidders.rotate.first
      end

      def everyone_passed?
        passed_count == 4
      end

      def passed_count
        passes = @bids["pass"]

        if passes.nil?
          0
        else
          passes.count
        end
      end
      private :passed_count

      def next_bidder!
        @bidders.rotate!.first
      end
      private :next_bidder!

      def winning_bidder
        @bids[@highest_bid.to_s].first
      end

      def valid_bids
        Bid.all_bids.select {|b| valid_bid?(b) }
      end
    end
  end
end
