require "spec_helper"

module FiveHundred
  module Wrapper
    describe "game wrapper" do
      def set_current_bidder(bidder_position=0)
        @gw.instance_variable_get(:@current_round).send(:set_current_bidder, @gw.instance_variable_get(:@game).players[bidder_position])
      end

      def set_bid_winner(bidder_position=0)
        @gw.instance_variable_get(:@current_round).instance_variable_set(:@state, :kitty)
        @gw.instance_variable_get(:@current_round).instance_variable_set(:@winning_bidder, @gw.instance_variable_get(:@game).players[bidder_position])
      end


      before(:each) do
        @game = double("Game")
        @round = double("Round")
        @game.stub(:rounds).and_return([@round])
        @gw = GameWrapper.new
        @gw.instance_variable_set(:@game, @game)
        @gw.run!
      end

      context "message queue" do
        it "should have new round" do
          @gw.messages.first.msg.should == :new_round
          @gw.has_messages?.should == true
        end

        it "should have ai bid" do
          set_current_bidder
          @gw.run!

          @gw.messages[1].msg.should == :ai_bid
        end

        it "should have request player bid" do

          set_current_bidder(3)
          @gw.run!

          @gw.messages[1].msg.should == :request_player_bid
        end

        it "should have ai kitty" do
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
