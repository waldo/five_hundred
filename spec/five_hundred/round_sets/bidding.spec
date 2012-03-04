# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module RoundSets
    describe "bidding" do
      include_context "game support"
      include_context "named bids"

      before(:each) do
        @bidding = Bidding.new(@players.dup)
      end

      it "should determine validity of bids" do
        @bidding.valid_bid?(@bid_6h).should be_true
        @bidding.valid_bid?(@bid_cm).should be_false
        @bidding.valid_bid?(@pass).should be_true
        @bidding.valid_bid?(nil).should be_false
      end

      it "should set bid" do
        @bidding.bid(@bid_8h)
        @bidding.highest_bid.should == @bid_8h
      end

      it "should recognise invalid bids" do
        @bidding.bid(@bid_7d)
        @bidding.valid_bid?(@bid_7d).should be_false
      end

      it "should set a new current bidder once a player has bid" do
        bidder = @bidding.current_bidder
        next_bidder = @bidding.next_bidder
        @bidding.bid(@bid_8h)
        @bidding.current_bidder.should_not == bidder
        @bidding.current_bidder.should == next_bidder
      end

      it "should have first player as next bidder if last player is current bidder" do
        @bidding.send(:next_bidder!)
        @bidding.send(:next_bidder!)
        @bidding.send(:next_bidder!)
        @bidding.send(:next_bidder!)
        @bidding.current_bidder.should == @players[0]
      end

      context "check if bidding is complete" do
        it "should end if there is a bid and 3 players pass" do
          @bidding.bid(@pass)
          @bidding.bid(@pass)
          @bidding.bid(@pass)
          @bidding.complete?.should be_false
          @bidding.everyone_passed?.should be_false

          @bidding.bid(@bid_6h)
          @bidding.complete?.should be_true
          @bidding.everyone_passed?.should be_false
        end

        it "should end if 10 no trumps is called" do
          @bidding.bid(@pass)
          @bidding.bid(@pass)
          @bidding.bid(@bid_10nt)

          @bidding.winning_bidder.should == @players[2]
          @bidding.complete?.should be_true
        end

        it "should end if all 4 players pass" do
          @bidding.bid(@pass)
          @bidding.bid(@pass)
          @bidding.bid(@pass)
          @bidding.bid(@pass)

          @bidding.everyone_passed?.should be_true
          @bidding.complete?.should be_false
        end

        it "should assign the correct winning bidder" do
          @bidding.bid(@pass)
          @bidding.bid(@pass)
          @bidding.bid(@pass)
          @bidding.complete?.should be_false
          @bidding.everyone_passed?.should be_false

          @bidding.bid(@bid_6h)
          @bidding.winning_bidder.should == @players[3]

          @bidding = Bidding.new(@players.dup)
          @bidding.bid(@pass)
          @bidding.bid(@bid_6h)
          @bidding.bid(@pass)
          @bidding.complete?.should be_false
          @bidding.everyone_passed?.should be_false

          @bidding.bid(@pass)
          @bidding.winning_bidder.should == @players[1]
        end
      end

      context "valid bids" do
        it "should return all bids except closed misere if no bid" do
          @bidding.valid_bids.should == [
            @bid_6s, @bid_6c, @bid_6d, @bid_6h, @bid_6nt,
            @bid_7s, @bid_7c, @bid_7d, @bid_7h, @bid_7nt,
            @bid_8s, @bid_8c, @bid_8d, @bid_8h, @bid_8nt,
            @bid_9s, @bid_9c, @bid_9d, @bid_9h, @bid_9nt,
            @bid_10s, @bid_10c, @bid_10d, @bid_10h,
            @bid_om,
            @bid_10nt,
            @pass,
          ]
        end

        it "should have the same bids before and after pass bids" do
          @bidding.bid(@bid_10d)
          @bidding.valid_bids.should == [
            @bid_10h,
            @bid_om,
            @bid_10nt,
            @pass,
          ]

          @bidding.bid(@pass)
          @bidding.valid_bids.should == [
            @bid_10h,
            @bid_om,
            @bid_10nt,
            @pass,
          ]
        end

        it "should remove the last bid and bids lower than the last bid" do
          @bidding.bid(@bid_9d)
          @bidding.valid_bids.should == [
            @bid_9h, @bid_9nt,
            @bid_10s, @bid_10c, @bid_10d, @bid_10h,
            @bid_om,
            @bid_10nt,
            @pass,
          ]

          @bidding = Round.new(@game)
          @bidding.bid(@bid_6nt)
          @bidding.valid_bids.should == [
            @bid_7s, @bid_7c, @bid_7d, @bid_7h, @bid_7nt,
            @bid_8s, @bid_8c, @bid_8d, @bid_8h, @bid_8nt,
            @bid_9s, @bid_9c, @bid_9d, @bid_9h, @bid_9nt,
            @bid_10s, @bid_10c, @bid_10d, @bid_10h,
            @bid_om,
            @bid_10nt,
            @pass,
          ]
        end

        it "shouldn't contain closed misére unless bid is in the sevens" do
          @bidding.bid(@bid_6h)
          @bidding.valid_bids.should_not include(@bid_cm)

          @bidding.bid(@bid_7s)
          @bidding.valid_bids.should include(@bid_cm)
        end

        it "shouldn't contain closed misére if bids are 8 or over" do
          @bidding.bid(@bid_8s)
          @bidding.valid_bids.should_not include(@bid_cm)
        end

        it "should contain pass" do
          @bidding.valid_bids.should include(@pass)

          @bidding.bid(@bid_7s)
          @bidding.valid_bids.should include(@pass)

          @bidding.bid(@bid_om)
          @bidding.valid_bids.should include(@pass)
        end

        it "should have no valid bids after 10nt has been bid" do
          @bidding.bid(@bid_10nt)
          @bidding.valid_bids.should == []
        end
      end
    end
  end
end
