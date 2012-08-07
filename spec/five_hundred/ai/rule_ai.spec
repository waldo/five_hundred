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
        @ai = RuleAI.new

        @game.stub(:current_round).and_return(@round)
        @round.stub(:highest_bid).and_return(@bid_10d)
        @round.stub(:trump_suit).and_return(:hearts)
        @round.stub(:valid_bids).and_return([@bid_10d, @bid_10h, @bid_om, @bid_10nt, @pass])
        @card_arr = [@joker, @jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ten_hearts, @nine_hearts, @eight_hearts, @seven_hearts]
        @round.stub(:valid_cards).and_return(@card_arr)

        @ai.game = @game
        @ai.assign_cards(@card_arr)
      end

      context "should respond to requests for" do
        it "bid with a valid bid from the suit it has with most cards" do
          bid = @ai.request(:bid)

          @round.valid_bids.should include(bid)
        end

        it "bid and be 10 or less" do
          @ai.request(:bid).should == @bid_10h
        end

        it "kitty with the 3 lowest cards from your hand" do
          cards = @ai.request(:kitty)

          cards.should == [@seven_hearts, @eight_hearts, @nine_hearts]
        end

        it "play with a card from your hand" do
          card = @ai.request(:play)

          @ai.cards.should include(card)
          @round.valid_cards.should include(card)
        end

        context "(non-misere)" do
          context "playing first" do
          end

          context "playing second / third shared" do
          end

          context "playing third additional strategy" do
          end

          context "playing fourth" do
          end
        end
      end

      describe "one valid choice" do
        it "returns true when only one cards is valid" do
          @ai.one_valid_choice?([@seven_hearts]).should be_true
        end

        it "returns false when multiple cards are valid" do
          @ai.one_valid_choice?([@seven_hearts, @six_spades, @six_clubs]).should be_false
        end
      end

      describe "guaranteed winner" do
        it "returns true if the set includes the strongest remaining card" do
          @ai.guaranteed_winner?([@jack_hearts, @seven_hearts], @jack_hearts).should be_true
        end

        it "returns false if the set doesn't include the strongest remaining card" do
          @ai.guaranteed_winner?([@jack_diamonds, @seven_hearts], @jack_hearts).should be_false
        end
      end
    end
  end
end