require "spec_helper"

module FiveHundred
  module Wrapper
    describe "game wrapper" do
      include_context "named cards"
      include_context "named bids"
      before(:each) do
        @game = double("Game").as_null_object
        @round = double("Round").as_null_object
        @next_round = double("Round").as_null_object
        @ai = double("Player").as_null_object
        @trick = double("Trick").as_null_object
        @next_trick = double("Trick").as_null_object
        @player = double("Player").as_null_object

        @game.stub(:current_round => @round)

        @gw = GameWrapper.new
        @gw.instance_variable_set(:@game, @game)
        @gw.instance_variable_set(:@current_round, @round)
      end

      context "message queue" do
        it "should have a new round message" do
          @gw.messages.first.msg.should == :new_round
          @gw.has_messages?.should be_true
        end

        it "should have an ai bid message" do
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

        it "should have a request player bid message" do
          @round.stub(:state).and_return(:bidding)
          @round.stub(:current_bidder).and_return(@gw.instance_variable_get(:@player))
          @gw.send(:run)

          @gw.messages.last.msg.should == :request_player_bid
        end

        it "should have an ai kitty message" do
          @round.stub(:state).and_return(:kitty)
          @round.stub(:winning_bidder).and_return(@ai)
          @round.should_receive(:discard_kitty)
          @gw.send(:run)

          @gw.messages.last.msg.should == :ai_kitty_discard
        end

        it "should have a request player kitty message" do
          @round.stub(:state).and_return(:kitty)
          @round.stub(:winning_bidder).and_return(@gw.instance_variable_get(:@player))
          @gw.send(:run)

          @gw.messages.last.msg.should == :request_player_kitty_discard
        end

        it "should have an ai play card message" do
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

        it "should have a request player play card message" do
          @round.stub(:state).and_return(:playing)
          @round.stub(:current_player).and_return(@gw.instance_variable_get(:@player))
          @gw.send(:run)

          @gw.messages.last.msg.should == :request_player_play_card
        end

        it "should have a trick over message" do
          @gw.instance_variable_set(:@current_trick, @trick)
          @round.stub(:tricks).and_return([@next_trick])
          @game.stub_chain(:players, :find).and_return(0)
          @gw.send(:check_trick_change)

          @gw.messages.last.msg.should == :trick_over
          @gw.messages.last.player_position.should == 0
        end

        it "should have a round over message" do
          @game.stub(:current_round => @next_round)
          @gw.send(:check_round_change)

          @gw.messages.last.msg.should == :round_over
        end

        it "should have a game over message" do
          @game.stub(:state).and_return(:complete)
          @gw.send(:check_game_over)

          @gw.messages.last.msg.should == :game_over
        end
      end

      context "should provide the state of the" do
        it "game scores" do
          @game.stub(:teams).and_return(["Team 1 mock", "Team 2 mock"])
          @game.should_receive(:score_for).with("Team 1 mock").and_return("300")
          @game.should_receive(:score_for).with("Team 2 mock").and_return("-40")

          @gw.game_score_at_team_position(0) == "300"
          @gw.game_score_at_team_position(1) == "-40"
        end

        it "round scores" do
          @game.stub(:teams).and_return(["Team 1 mock", "Team 2 mock"])
          @round.should_receive(:score_for).with("Team 1 mock").and_return("-400")
          @round.should_receive(:score_for).with("Team 2 mock").and_return("20")

          @gw.round_score_at_team_position(0) == "-400"
          @gw.round_score_at_team_position(1) == "20"
        end

        it "player's cards" do
          @player.stub(:cards).and_return([@joker, @ace_hearts, @ten_hearts])
          @gw.instance_variable_set(:@player, @player)

          @gw.get_card_codes.should == ["Jo", "Ah", "10h"]
        end

        it "kitty cards" do
          @player.stub(:kitty_cards).and_return([@joker, @six_spades, @ten_diamonds])
          @gw.instance_variable_set(:@player, @player)

          @gw.get_kitty_card_codes.should == ["Jo", "6s", "10d"]
        end

        it "valid bids" do
          @round.should_receive(:valid_bids).and_return([@pass, @bid_10d, @bid_10h, @bid_om, @bid_10nt])

          @gw.valid_bids.should == ["pass", "10d", "10h", "om", "10nt"]
        end

        it "valid cards to play" do
          @round.should_receive(:valid_cards).and_return([@six_spades, @seven_spades, @ace_spades, @joker])

          @gw.valid_cards.should == ["6s", "7s", "As", "Jo"]
        end

        it "round's highest bid" do
          @game.stub(:teams).and_return(["Team 1 mock", "Team 2 mock"])
          @round.stub_chain(:winning_bidder, :team).and_return("Team 1 mock")
          @round.stub(:highest_bid).and_return(@bid_8h)

          @gw.bid_at_team_position(0).should == "8h"
          @gw.bid_at_team_position(1).should == ""
        end

        it "round's tricks won per team" do
          @game.stub(:teams).and_return(["Team 1 mock", "Team 2 mock"])
          @round.stub(:tricks_won_for).with("Team 1 mock").and_return("4")
          @round.stub(:tricks_won_for).with("Team 2 mock").and_return("2")

          @gw.tricks_won_at_team_position(0) == "4"
          @gw.tricks_won_at_team_position(1) == "2"
        end

        it "game winner" do
          @game.stub(:players).and_return(@player * 4)
          @player.stub(:team).and_return("Team 1 mock", "Team 2 mock", "Team 1 mock", "Team 2 mock")
          @game.stub(:winner).and_return("Team 2 mock")

          @gw.game_winner_at_player_position(0) == false
          @gw.game_winner_at_player_position(1) == true
          @gw.game_winner_at_player_position(2) == false
          @gw.game_winner_at_player_position(3) == true
        end
      end

      context "should accept" do
        it "player bid" do
          @round.should_receive(:bid).with(@bid_6h)

          @gw.player_bid("6h")
        end

        it "player discard kitty" do
          @round.should_receive(:discard).with([@five_diamonds, @ten_clubs, @nine_clubs])

          @gw.player_discard_kitty(["5d", "10c", "9c"])
        end

        it "player play card" do
          @round.should_receive(:play_card).with(@five_diamonds)

          @gw.player_play_card("5d")
        end
      end
    end
  end
end
