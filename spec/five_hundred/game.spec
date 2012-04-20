# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "game" do
    include_context "game support"

    before(:each) do
      @g = Game.new
      @p = Player.new
      @t1 = @g.teams.first
      @t2 = @g.teams.last
    end

    context "creation" do
      it "" do
        @g.state.should == :setup
        @g.teams.count.should == 2
      end
    end

    context "join" do
      it "shouldn't allow the same player twice" do
        @g.join(@p, @t1).join(@p, @t2)

        @t1.players.count.should == 1
        @t2.players.count.should == 0
      end

      it "should assign players with teams" do
        @g.join(Player.new, @t1).join(Player.new, @t1)
        @g.join(Player.new, @t2).join(Player.new, @t2)

        @t1.players.count.should == 2
        @t2.players.count.should == 2
      end

      it "should assign players without selecting teams" do
        add_players
        @t1.players.count.should == 2
        @t2.players.count.should == 2
      end

      it "should set player order so positions 0 and 1 are not held by the same team" do
        add_players
        [@t1, @t2].each do |t|
          (@g.players.index(t.players.first) - @g.players.index(t.players.last)).abs.should == 2
        end
      end
    end

    context "start first round" do
      it "should assign a player as the 'dealer'" do
        add_players
        @g.players.should include(@g.current_dealer)
        @g.current_dealer.nil?.should be_false
      end

      it "shouldn't happen if there are 3 players" do
        add_players(3)
        @g.state.should_not == :in_progress
      end
    end

    context "round complete -" do
      def round_stub!(scores, bids_achieved, winning_bidder=@g.players.first)
        @g.teams.each_with_index do |t,i|
          @round.stub(:score_for).with(t) { scores[i] }
          @round.stub(:bid_achieved_for?).with(t) { bids_achieved[i] }
        end

        @round.stub(:winning_bidder) { winning_bidder }
      end

      before(:each) do
        add_players
        @round = double("Round")
        @g.stub(:current_round).and_return(@round)
        @g.instance_variable_set(:@rounds, [@round])
      end

      context "should end the game" do
        context "when team achieved their bid and total score is 500+ points" do
          it "" do
            round_stub!([500, -200], [true, nil])

            @g.round_complete
            @g.state.should == :complete
            @g.winner.should == @g.teams.first
          end

          it "across multiple rounds" do
            @g.instance_variable_set(:@rounds, [@round, @round, @round])
            round_stub!([180, 20], [true, nil])

            @g.round_complete
            @g.state.should == :complete
            @g.winner.should == @g.teams.first
          end

          it "even though other team has a higher score" do
            round_stub!([520, 500], [nil, true], @g.players.last)

            @g.round_complete
            @g.state.should == :complete
            @g.winner.should == @g.teams.last
          end
        end

        it "when team drops below -500 points" do
          round_stub!([-500, -490], [false, nil])

          @g.round_complete
          @g.state.should == :complete
          @g.winner.should == @g.teams.last
        end
      end

      context "should not end the game" do
        context "when a team is over 500 but" do
          it "didn't achieve the bid" do
            round_stub!([520, 480], [false, nil])

            @g.round_complete
            @g.state.should == :in_progress
            @g.winner.should == []
          end

          it "the other team bid" do
            round_stub!([480, 520], [true, nil])

            @g.round_complete
            @g.state.should == :in_progress
            @g.winner.should == []
          end
        end

        it "and start a new round when game is not over" do
          round_stub!([480, 480], [true, nil])

          @g.round_complete
          @g.state.should == :in_progress
          @g.winner.should == []
        end
      end
    end
  end
end