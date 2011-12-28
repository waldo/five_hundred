# encoding: UTF-8
require "spec_helper"

describe "game" do
  def add_players(num=4)
    num.times do @g.join(Player.new) end
  end

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

  context "deal" do
    it "should assign a player as the 'dealer'" do
      add_players
      @g.players.should include(@g.current_dealer)
      @g.current_dealer.nil?.should == false
    end

    it "shouldn't happen if there are 3 players" do
      add_players(3)
      @g.state.should_not == :bidding
    end
  end
end