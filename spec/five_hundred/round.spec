# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "round" do
    include_context "game support"
    include_context "named cards"
    include_context "named bids"

    before(:each) do
      @ts = double("TrickSet").as_null_object
      @players = Array.new(4) { Player.new }
      @game.stub(:players).and_return(@players)
      @game.stub(:next_dealer).and_return(@players.first)
      @game.stub(:current_dealer).and_return(@players.last)

      @r = Round.new(@game)
    end

    context "initialising / dealing" do
      it "should distribute cards to each player" do
        @game.players.each do |p|
          p.cards.count.should == 10
        end
      end
    end

    context "bidding" do
      it "" do
        @r.state.should == :bidding
      end

      it "should accept bid only during bidding phase" do
        @r.bid(@bid_6h)
        @r.highest_bid.should == @bid_6h

        @r.stub(:state).and_return(:playing)
        @r.bid(@bid_7d)
        @r.highest_bid.should_not == @bid_7d
      end

      it "should move to kitty assignment state on successful completion of bidding round" do
        @r.bid(@bid_7d)
        @r.bid(@pass)
        @r.bid(@pass)
        @r.bid(@pass)

        @r.state.should == :kitty
      end

      it "should move to complete state if all players pass" do
        @r.bid(@pass)
        @r.bid(@pass)
        @r.bid(@pass)
        @r.bid(@pass)

        @r.state.should == :complete
      end
    end

    context "kitty" do
      before(:each) do
        @r.bid(@bid_6h)
        @r.bid(@pass)
        @r.bid(@pass)
        @r.bid(@pass)
      end

      it "should give 3 cards to winning bidder" do
        @r.start_kitty_phase!

        @game.players[0].kitty.count.should == 3
        @r.state.should == :kitty
      end

      it "should not accept discard unless in the kitty phase" do
        @r = Round.new(@game)

        @r.discard_valid?(@players[0].cards.slice(0..2)).should be_false
      end

      it "should have winning bidder give back exactly 3 cards" do
        @r.discard_valid?(@players[0].cards.slice(0..2)).should be_true
      end

      it "should not accept winning bidder providing 1 or 2 cards" do
        @r.discard_valid?(@players[0].cards.slice(0..0)).should be_false
        @r.discard_valid?(@players[0].cards.slice(0..1)).should be_false
      end

      it "should only discard 3 different cards" do
        @r.discard_valid?([@four_diamonds, @four_diamonds, @four_diamonds]).should be_false
        @r.discard_valid?([@four_diamonds, @five_diamonds, @four_diamonds]).should be_false
      end
    end

    context "playing" do
      before :each do
        @r.bid(@bid_6h)
        @r.bid(@pass)
        @r.bid(@pass)
        @r.bid(@pass)
        @r.discard!(@players[0].cards.slice(0..2))
      end

      it "" do
        @r.state.should == :playing
      end

      it "should give the bid winner the first turn" do
        @r.trick_set.current_player.should == @r.winning_bidder
      end

      it "should accept play card only during playing phase, not during bidding phase" do
        @r.play(@players[0].cards.first)

        @players[0].cards.count.should == 9

        @r = Round.new(@game)
        @r.play(@players[0].cards.first)

        @players[0].cards.count.should == 10
      end

      it "should move to complete state on successful completion of playing round" do
        @r.stub(:tricks_phase_complete?).and_return(true)
        @r.play(@six_hearts)

        @r.state.should == :complete
      end
    end

    context "scoring" do
      it "should determine if the bid is achieved" do
        @r.stub(:highest_bid).and_return(@bid_6h)
        @r.stub(:winning_bidder).and_return(@players[0])
        @r.stub(:tricks_won_for).with(@players[0].team).and_return(6)
        @r.stub(:tricks_won_for).with(@players[1].team).and_return(4)

        @r.score_for(@players[0].team).should == 100
        @r.score_for(@players[1].team).should == 40
        @r.bid_achieved_for?(@players[0].team).should be_true
        @r.bid_achieved_for?(@players[1].team).should be_nil
      end
    end
  end
end
