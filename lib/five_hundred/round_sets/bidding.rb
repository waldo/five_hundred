# encoding: UTF-8

module FiveHundred
  module RoundSets
    class Bidding
      attr_reader :highest_bid

      def initialize(bidders)
        @bidders = bidders

        @highest_bid = Bid.empty
        @bid_entries = [{ player: Player.empty, bid: Bid.empty }]
      end

      def bid(new_bid)
        bid!(new_bid) if valid_bid?(new_bid)
      end

      def bid!(new_bid)
        @bid_entries << { player: current_bidder, bid: new_bid }
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
        @bid_entries.count {|entry| entry[:bid].passed? }
      end
      private :passed_count

      def next_bidder!
        @bidders.rotate!.first
      end
      private :next_bidder!

      def winning_bidder
        @bid_entries.select {|entry| !entry[:bid].passed? }.last[:player]
      end

      def valid_bids
        Bid.all_bids.select {|bid| valid_bid?(bid) }
      end

      def bid_for_player(player)
        player_bid = Bid.empty

        @bid_entries.each do |bid|
          player_bid = bid[:bid] if player == bid[:player]
        end

        player_bid
      end
    end
  end
end
