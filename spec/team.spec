require "spec_helper"

describe "team" do
  context "join" do
    it "should work" do
      Team.new.join(Player.new).players.count.should == 1
    end

    it "shouldn't allow more than 2 players" do
      p = Player.new
      t = Team.new.join(Player.new).join(Player.new).join(p)

      t.players.should_not include(p)

      t.players.count.should == 2
    end

    it "shouldn't allow the same player twice" do
      p = Player.new
      t = Team.new.join(p).join(p)

      t.players.count.should == 1
    end
  end

  context "should store tricks won" do
    it "initially as zero" do
      Team.new.tricks_won.should == 0
    end

    it "and increment them" do
      t = Team.new
      t.add_trick_won
      t.tricks_won.should == 1
    end
  end
end