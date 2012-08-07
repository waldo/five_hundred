# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module AI
    describe "ai" do
      include_context "game support"
      include_context "named bids"
      include_context "named cards"

      before(:each) do
        @round = double("Round").as_null_object
        @ai = RandomAI.new

        @game.stub(:current_round).and_return(@round)
        @round.stub(:highest_bid).and_return(@bid_6h)
        @round.stub(:trump_suit).and_return(:hearts)
        @round.stub(:valid_bids).and_return([@bid_10d, @bid_10h, @bid_om, @bid_10nt, @pass])
        @round.stub(:valid_cards).and_return([@nine_hearts, @seven_hearts])

        @ai.game = @game
        @ai.assign_cards([@joker, @jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ten_hearts, @nine_hearts, @eight_hearts, @seven_hearts])
      end

      context "should respond to requests for" do
        it "bid with a random valid bid" do
          bid = @ai.request(:bid)

          @round.valid_bids.should include(bid)
        end

        it "kitty with 3 random cards from your hand" do
          @ai.assign_kitty([@five_spades, @five_clubs, @four_diamonds])

          cards = @ai.request(:kitty)
          cards.count.should == 3
          cards.each do |c|
            (@ai.cards + @ai.kitty).should include(c)
          end
        end

        it "play with a card from your hand" do
          card = @ai.request(:play)

          @ai.cards.should include(card)
          @round.valid_cards.should include(card)
        end
      end
    end
  end
end
