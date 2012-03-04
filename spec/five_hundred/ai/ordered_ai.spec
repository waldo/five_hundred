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
        @ai = OrderedAI.new

        @game.stub(:current_round).and_return(@round)
        @round.stub(:highest_bid).and_return(@bid_6h)
        @round.stub(:trump_suit).and_return(:hearts)
        @ai.assign_cards([@joker, @jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ten_hearts, @nine_hearts, @eight_hearts, @seven_hearts])
      end

      context "should respond to requests for" do
        it "bid with a valid bid from the suit it has with most cards" do
          bid = @ai.request(:bid, @game)
          Bid.all.keys.should include(bid.code)
        end

        it "bid and be 10 or less" do
          @ai.request(:bid, @game).should == @bid_10h
        end

        it "kitty with 3 random low cards from your hand" do
          @round.stub(:highest_bid).and_return(@bid_6h)

          cards = @ai.request(:kitty, @game)
          cards.count.should == 3
          cards.each do |c|
            @ai.cards.should include(c)
          end
          cards.should_not include(@joker)
        end

        it "play with a card from your hand" do
          card = @ai.request(:play, @game)
          @ai.cards.should include(card)
        end

        context "play the joker" do
          it do
            @ai.request(:play, @game).should == @joker
          end

          it "in misére or no trumps round" do
            @round.stub(:trump_suit).and_return(:none)

            @ai.request(:play, @game).should == @joker
          end
        end
      end
    end
  end
end