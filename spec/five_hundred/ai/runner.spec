require "spec_helper"

module FiveHundred
  module AI
    describe "runner" do
      it "should take 1, 2 or 4 ai" do
        ais = [RandomAI]
        r = Runner.new(10, ais)
        r.players.count.should == 4

        ais = [RandomAI] * 2
        r = Runner.new(10, ais)
        r.players.count.should == 4

        ais = [RandomAI] * 3
        r = Runner.new(10, ais)
        r.players.count.should == 3

        ais = [RandomAI] * 4
        r = Runner.new(10, ais)
        r.players.count.should == 4
      end

      it "should keep two different ais on opposing teams" do
        r_ai = RandomAI
        o_ai = OrderedAI
        ais = [r_ai, o_ai]
        r = Runner.new(10, ais)
        r.players[0].class.should == r.players[1].class
        r.players[2].class.should == r.players[3].class
      end
    end
  end
end