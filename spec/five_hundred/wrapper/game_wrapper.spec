require "spec_helper"

module FiveHundred
  module Wrapper
    describe "game wrapper" do
      before(:each) do
        @game = double("Game").as_null_object
        @round = double("Round").as_null_object
        @ai = double("Player").as_null_object
        @gw = GameWrapper.new
        @gw.instance_variable_set(:@game, @game)
        @gw.instance_variable_set(:@current_round, @round)
      end

      context "message queue" do
        it "should have new round" do
          @gw.messages.first.msg.should == :new_round
          @gw.has_messages?.should == true
        end

        it "should have ai bid" do
          @round.stub(:state).and_return(:bidding)
          @round.stub(:current_bidder).and_return(@ai)
          @round.should_receive(:bid)
          @game.stub_chain(:players, :find).and_return(3)
          bid = double("Bid").as_null_object
          bid.stub(:code).and_return("6s")
          @ai.should_receive(:request).with(:bid, @game).and_return(bid)
          @gw.send(:run)

          @gw.messages.last.msg.should == :ai_bid
          @gw.messages.last.player_position.should == 3
          @gw.messages.last.bid.should == "6s"
        end

        it "should have request player bid" do
          @round.stub(:state).and_return(:bidding)
          @round.stub(:current_bidder).and_return(@gw.instance_variable_get(:@player))
          @gw.send(:run)

          @gw.messages.last.msg.should == :request_player_bid
        end

        it "should have ai kitty" do
          @round.stub(:state).and_return(:kitty)
          @round.stub(:winning_bidder).and_return(@ai)
          @round.should_receive(:discard)
          @gw.send(:run)

          @gw.messages.last.msg.should == :ai_kitty
        end

        it "should request player kitty" do
          @round.stub(:state).and_return(:kitty)
          @round.stub(:winning_bidder).and_return(@gw.instance_variable_get(:@player))
          @gw.send(:run)

          @gw.messages.last.msg.should == :request_player_kitty
        end

        it "should have ai play card" do
          @round.stub(:state).and_return(:playing)
          @round.stub(:current_player).and_return(@ai)
          @round.should_receive(:play_card)
          @game.stub_chain(:players, :find).and_return(3)
          @ai.should_receive(:request).with(:play, @game).and_return("Qd")
          @gw.send(:run)

          @gw.messages.last.msg.should == :ai_play_card
          @gw.messages.last.player_position.should == 3
          @gw.messages.last.card.should == "Qd"
        end

        it "should request player play card" do
          @round.stub(:state).and_return(:playing)
          @round.stub(:current_player).and_return(@gw.instance_variable_get(:@player))
          @gw.send(:run)

          @gw.messages.last.msg.should == :request_player_play_card
        end

        it "should have trick over" do
          pending
          @round.stub(:state).and_return(:playing)
        end

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
