# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "round" do
    include_context "game support"
    include_context "named cards"
    include_context "named bids"

    before(:each) do
      @r = Round.new(@game)
      @pass = Bid.new("pass")
      @ts = double("TrickSet").as_null_object
    end

    context "initialising / dealing" do
      it "should distribute cards to each player" do
        @game.players.each do |p|
          p.should_receive(:assign_cards)
        end

        Round.new(@game)
      end
    end

    context "bidding" do
      it "" do
        @r.state.should == :bidding
      end

      it "should accept bid only during bidding phase" do
        @r.stub(:state).and_return(:bidding)
        @r.should_receive(:check_after_bid).once
        @r.bid(@bid_6h)

        @r.stub(:state).and_return(:playing)
        @r.should_not_receive(:check_after_bid)
        @r.bid(@bid_7d)
      end

      it "should move to kitty assignment state on successful completion of bidding round" do
        @r.stub(:bidding_complete?).and_return(true)
        @r.bid(@bid_7d)

        @r.state.should == :kitty
      end

      it "should move to complete state if all players pass" do
        @r.stub(:everyone_passed?).and_return(true)
        @r.bid(@pass)

        @r.state.should == :complete
      end
    end

    context "kitty assignment" do
      it "should give 3 cards to winning bidder" do
        @r.stub(:winning_bidder).and_return(@players[3])
        @players[3].should_receive(:assign_kitty)

        @r.start_kitty_phase!
        @r.state.should == :kitty
      end
    end

    context "kitty discard" do
      before(:each) do
        @r.stub(:winning_bidder).and_return(@players[0])
        @r.stub(:state).and_return(:kitty)
      end

      it "should not accept discard unless in the kitty phase" do
        @r.stub(:state).and_return(:bidding)
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
        @r.stub(:state).and_return(:playing)
        @r.stub(:trick_set).and_return(@ts)
      end

      it "should accept play card only during playing phase" do
        @r.should_receive(:check_after_play).once
        @r.play(@queen_hearts)

        @r.stub(:state).and_return(:bidding)
        @r.should_not_receive(:check_after_play)
        @r.play(@ace_diamonds)
      end

      it "should move to complete state on successful completion of playing round" do
        @r.stub(:tricks_phase_complete?).and_return(true)
        @r.play(@six_hearts)
        @r.unstub(:state)

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
