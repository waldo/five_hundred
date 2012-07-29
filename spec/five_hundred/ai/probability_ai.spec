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
        @ai = ProbabilityAI.new

        @game.stub(:current_round).and_return(@round)
        @game.stub(:players).and_return(([double("Player").as_null_object] * 3) << @ai)
        @round.stub(:highest_bid).and_return(@bid_6h)
        @round.stub(:trump_suit).and_return(:hearts)
        @round.stub(:valid_bids).and_return([@bid_7h, @bid_10d, @bid_10h, @bid_om, @bid_10nt, @pass])
        @card_arr = [@jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ace_spades, @eight_spades, @six_spades, @queen_clubs, @seven_clubs]
        @round.stub(:valid_cards).and_return(@card_arr)
        @ai.assign_cards(@card_arr)
      end

      context "should respond to requests for" do
        it "bid with a valid bid from the suit it has with most cards" do
          bid = @ai.request(:bid, @game)

          @round.valid_bids.should include(bid)
        end

        it "bid and be 10 or less" do
          @ai.request(:bid, @game).should == @bid_7h
        end

        context "play" do
          it "starts with a default probability for cards per player given my known cards" do
            @ai.assign_cards([@joker, @jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ten_hearts, @nine_hearts, @eight_hearts, @seven_hearts])
            @ai.request(:bid, @game)

            @ai.probabilities[3][@joker.code].should == 1.0
            @ai.probabilities[0][@joker.code].should == 0.0
            @ai.probabilities[:kitty][@joker.code].should == 0.0

            @ai.probabilities[3][@four_hearts.code].should == 0.0
            @ai.probabilities[0][@four_hearts.code].should == 10.0 / 33.0
            @ai.probabilities[:kitty][@four_hearts.code].should == 3.0 / 33.0
          end

          it "updates probability after you got the kitty" do
            @round.stub(:winning_bidder).and_return(@ai)
            @ai.assign_cards([@joker, @jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ten_hearts, @nine_hearts, @eight_hearts, @seven_hearts])
            @ai.assign_kitty([@four_diamonds, @four_hearts, @five_spades])
            @ai.request(:kitty, @game)

            @ai.probabilities[3][@eight_spades.code].should == 0.0
            @ai.probabilities[0][@eight_spades.code].should == 10.0 / 30.0
            @ai.probabilities[:kitty][@eight_spades.code].should == 0.0

            @ai.probabilities[3][@four_hearts.code].should == 1.0
            @ai.probabilities[0][@four_hearts.code].should == 0.0
            @ai.probabilities[:kitty][@four_hearts.code].should == 0.0
          end

          it "updates probability after you discard the kitty" do
            @round.stub(:winning_bidder).and_return(@ai)
            @ai.assign_cards([@joker, @jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ten_hearts, @nine_hearts, @eight_hearts, @seven_hearts])
            @ai.assign_kitty([@four_diamonds, @four_hearts, @five_spades])
            cards = @ai.request(:kitty, @game)
            @ai.discard_kitty(cards)

            @ai.probabilities[3][@eight_spades.code].should == 0.0
            @ai.probabilities[0][@eight_spades.code].should == 10.0 / 30.0
            @ai.probabilities[:kitty][@eight_spades.code].should == 0.0

            @ai.probabilities[3][@four_hearts.code].should == 0.0
            @ai.probabilities[0][@four_hearts.code].should == 0.0
            @ai.probabilities[:kitty][@four_hearts.code].should == 1.0
          end

          it "updates probability after each card played"
          it "updates probability on voided suit"
          it "**updates probability on unknown kitty"
          it "**updates probability on counted cards"


          it "with a card from your hand" do
            card = @ai.request(:play, @game)

            @ai.cards.should include(card)
          end


          # list_of_all_cards =
          # "As" =>

          # P1 = AS = 30.3%
          # P2 = AS = 30.3%
          # P3 = AS = 30.3%
          # P4 = AS = 0%
          # K = AS = 9.1%

          # context "(non-misere)" do
          #   it "takes my highest card and get the probability it winning"


          #   context "last position player" do
          #     context "if my team is winning or I don't have a winning card" do
          #       it "plays low"
          #     end

          #     context "if my team is losing and I have a winning card"
          #       it "plays lowest winner"
          #     end
          #   end

          #   context "third position" do
          #     context "if highest card remaining has already been played" do
          #       it "plays low"
          #     end

          #     context "if I have the highest card" do

          #     end
          #   end
          # end
        end
      end
    end
  end
end