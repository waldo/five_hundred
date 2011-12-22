require "spec_helper"

describe "game" do
  context "creation" do
    it "" do
      g = Game.new
      g.state.should == :setup
      g.teams.count.should == 2
    end
  end

  context "join" do
    it "shouldn't allow the same player twice" do
      p = Player.new
      g = Game.new
      t = g.teams.first
      g.join(p, t).join(p, t)

      t.players.count.should == 1
    end

    it "should assign players with teams" do
      g = Game.new
      t1 = g.teams.first
      g.join(Player.new, t1).join(Player.new, t1)
      t2 = g.teams.last
      g.join(Player.new, t2).join(Player.new, t2)

      t1.players.count.should == 2
      t2.players.count.should == 2
    end

    it "should assign players without selecting teams" do
      g = Game.new
      (1..4).each do |i| g.join(Player.new) end

      g.teams.first.players.count.should == 2
      g.teams.last.players.count.should == 2
    end
  end
end