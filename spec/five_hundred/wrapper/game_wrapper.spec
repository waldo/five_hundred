require "spec_helper"

module FiveHundred
  module Wrapper
    describe "game wrapper" do
      before(:each) do
        @game = double("Game").as_null_object
        @round = double("Round").as_null_object
        @game.stub(:rounds).and_return([@round])
        @gw = GameWrapper.new
        @gw.instance_variable_set(:@game, @game)
      end

      context "message queue" do
        it "should have new round" do
          @round.stub(:state).and_return(:bidding)
          @round.stub(:current_bidder).and_return(@gw.instance_variable_get(:@player))
          @gw.run!
          @gw.messages.first.msg.should == :new_round
          @gw.has_messages?.should == true
        end

        it "should have ai bid" do
          pending
          @round.stub(:state).and_return(:bidding)
          @round.stub(:current_bidder).and_return(:ai)
          @gw.run!

          @gw.messages[1].msg.should == :ai_bid
        end

        it "should have request player bid" do
          pending
          set_current_bidder(3)
          @gw.run!

          @gw.messages[1].msg.should == :request_player_bid
        end

        it "should have ai kitty" do
          pending
          set_bid_winner
          @gw.run!

          @gw.messages.any? do |m| m.msg == :ai_kitty end.should == true
        end

        it "should request player kitty"
        it "should have ai play card"
        it "should request player play card"
        it "should have trick over"
        it "should have round over"
        it "should have game over"
      end

      context "should access game state for" do
        it "game scores"
        it "round scores"
        it "player's cards"
        it "kitty cards"
        it "valid bids"
        it "valid cards to play"
        it "round's highest bid"
        it "round's tricks won per team"
        it "game winner"
      end

      context "should accept" do
        it "player bid"
        it "player discard kitty"
        it "player play card"
      end
    end
  end
end
