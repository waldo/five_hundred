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
  end
end