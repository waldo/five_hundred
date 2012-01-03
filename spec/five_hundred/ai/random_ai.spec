# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module AI
    describe "ai" do
      include_context "game support"
      include_context "round support"
      include_context "named bids"

      before(:each) do
        @g = FiveHundred::Game.new
        @ai = RandomAI.new
        @g.join(@ai)
        add_players(3)
        @r = @g.rounds.last
      end

      context "should respond to requests for" do
        it "bid with a random valid bid" do
          bid = @ai.request(:bid, @g)
          Bid.all.keys.should include(bid.code)
        end

        it "kitty with 3 random cards from your hand" do
          win_bid!(@bid_6h, @ai)

          cards = @ai.request(:kitty, @g)
          cards.count.should == 3
          cards.each do |c|
            @ai.cards.should include(c)
          end
        end

        it "play with a card from your hand" do
          win_bid!(@bid_6h, @ai)
          discard_cards!(@ai)

          card = @ai.request(:play, @g)
          @ai.cards.should include(card)
        end
      end
    end
  end
end