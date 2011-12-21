require "spec_helper"

describe "game" do
  context "creation" do
    it "" do
      Game.new.state.should == :setup
    end
  end
  
  context "join" do
    it "should work" do
      Game.new.join(Player.new)
    end

    it "shouldn't allow more than 4 players" do
      g = Game.new
      p = Player.new
      (1..4).each do |i|
        g.join(Player.new)
      end

      g.players.should_not include(p)

      g.players.count.should == 4
    end

    it "shouldn't ignore the same player joining twice" do
      p = Player.new
      g = Game.new
      g.join(p)
      g.join(p)

      g.players.count.should == 1
    end
  end
end