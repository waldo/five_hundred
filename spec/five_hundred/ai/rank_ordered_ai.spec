# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module AI
    describe "ai" do
      include_context "game support"
      include_context "named bids"
      include_context "named cards"

      before :each do
        @round = double("Round").as_null_object
        @ai = RankOrderedAI.new

        @game.stub(:current_round).and_return(@round)
        @round.stub(:highest_bid).and_return(@bid_6h)
        @round.stub(:trump_suit).and_return(:hearts)
        @round.stub(:valid_bids).and_return([@bid_7h, @bid_10d, @bid_10h, @bid_om, @bid_10nt, @pass])
        card_arr = [@jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ace_spades, @eight_spades, @six_spades, @queen_clubs, @seven_clubs]
        @round.stub(:valid_cards).and_return(card_arr)
        @ai.assign_cards(card_arr)
      end

      context "should respond to requests for" do
        it "bid with a valid bid from the suit it has with most cards" do
          bid = @ai.request(:bid, @game)

          @round.valid_bids.should include(bid)
        end

        it "bid and be 10 or less" do
          @ai.request(:bid, @game).should == @bid_7h
        end

        it "kitty with 3 low cards (short suiting where possible) from your hand" do
          cards = @ai.request(:kitty, @game)

          cards.should == [@seven_clubs, @queen_clubs, @six_spades]
        end

        it "play with a card from your hand" do
          card = @ai.request(:play, @game)

          @ai.cards.should include(card)
        end
      end
    end
  end
end