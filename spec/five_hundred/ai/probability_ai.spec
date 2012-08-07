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
        @trick_set = double("TrickSet").as_null_object
        @ai = ProbabilityAI.new
        @card_arr = [@joker, @jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ten_hearts, @nine_hearts, @eight_hearts, @seven_hearts]
        @players = []
        3.times { @players << double("Player").as_null_object }
        @players << @ai

        @game.stub(:current_round).and_return(@round)
        @game.stub(:players => @players)

        @round.stub(:highest_bid).and_return(@bid_6h)
        @round.stub(:trump_suit).and_return(:hearts)
        @round.stub(:valid_bids).and_return([@bid_10d, @bid_10h, @bid_om, @bid_10nt, @pass])
        @round.stub(:trick_set => @trick_set)
        @round.stub(:valid_cards).and_return(@card_arr)

        @trick_set.stub(:all_played_cards => [])
        @trick_set.stub(:played_cards).with(@players[0]).and_return([])
        @trick_set.stub(:played_cards).with(@players[1]).and_return([])
        @trick_set.stub(:played_cards).with(@players[2]).and_return([])
        @trick_set.stub(:played_cards).with(@players[3]).and_return([])
        @trick_set.stub(:voided_suits => [])

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

        context "play" do
          it "starts with a default probability for cards per player given my known cards" do
            @round.stub(:state).and_return(:bidding)
            @ai.request(:bid)

            @ai.probabilities[3][@joker.code].should == 1.0
            @ai.probabilities[0][@joker.code].should == 0.0
            @ai.probabilities[:kitty][@joker.code].should == 0.0

            @ai.probabilities[3][@four_hearts.code].should == 0.0
            @ai.probabilities[0][@four_hearts.code].should == 10.0 / 33.0
            @ai.probabilities[:kitty][@four_hearts.code].should == 3.0 / 33.0
          end

          it "updates probability after you got the kitty" do
            @round.stub(:winning_bidder).and_return(@ai)
            @ai.assign_kitty([@four_diamonds, @four_hearts, @five_spades])
            @ai.request(:kitty)

            @ai.probabilities[3][@eight_spades.code].should == 0.0
            @ai.probabilities[0][@eight_spades.code].should == 10.0 / 30.0
            @ai.probabilities[:kitty][@eight_spades.code].should == 0.0

            @ai.probabilities[3][@four_hearts.code].should == 1.0
            @ai.probabilities[0][@four_hearts.code].should == 0.0
            @ai.probabilities[:kitty][@four_hearts.code].should == 0.0
          end

          it "updates probability after you discard the kitty" do
            @round.stub(:winning_bidder).and_return(@ai)
            @ai.assign_kitty([@four_diamonds, @four_hearts, @five_spades])
            cards = @ai.request(:kitty)
            @ai.discard_kitty(cards)

            @ai.probabilities[3][@eight_spades.code].should == 0.0
            @ai.probabilities[0][@eight_spades.code].should == 10.0 / 30.0
            @ai.probabilities[:kitty][@eight_spades.code].should == 0.0

            @ai.probabilities[3][@four_hearts.code].should == 0.0
            @ai.probabilities[0][@four_hearts.code].should == 0.0
            @ai.probabilities[:kitty][@four_hearts.code].should == 1.0
          end

          it "updates probability after each card played" do
            @trick_set.stub(:all_played_cards).and_return([@four_hearts, @five_hearts, @six_hearts, @seven_hearts])
            @trick_set.stub(:played_cards).with(@game.players[0]).and_return(@four_hearts)
            @trick_set.stub(:played_cards).with(@game.players[1]).and_return(@five_hearts)
            @trick_set.stub(:played_cards).with(@game.players[2]).and_return(@six_hearts)
            @trick_set.stub(:played_cards).with(@ai).and_return(@seven_hearts)
            @ai.remove_card(@seven_hearts)

            @ai.request(:play)

            @ai.probabilities[3][@four_hearts.code].should == 0.0
            @ai.probabilities[0][@four_hearts.code].should == 0.0
            @ai.probabilities[:kitty][@four_hearts.code].should == 0.0

            @ai.probabilities[3][@seven_hearts.code].should == 0.0
            @ai.probabilities[0][@seven_hearts.code].should == 0.0
            @ai.probabilities[:kitty][@seven_hearts.code].should == 0.0
          end

          it "updates probability on voided suit" do
            @trick_set.stub(:voided_suits).with(@game.players[0]).and_return([:clubs])

            @ai.request(:play)

            @ai.probabilities[0][@five_spades.code].should == 10.0 / 33.0

            @ai.probabilities[0][@five_clubs.code].should == 0.0
            @ai.probabilities[0][@ten_clubs.code].should == 0.0
            @ai.probabilities[0][@ace_clubs.code].should == 0.0

            @ai.probabilities[1][@five_clubs.code].should == 10.0 / 23.0
            @ai.probabilities[1][@ten_clubs.code].should == 10.0 / 23.0
            @ai.probabilities[1][@ace_clubs.code].should == 10.0 / 23.0
          end

          it "updates probability on unknown kitty - give winning bidder +3 slots for the whole round" do
            @round.stub(:winning_bidder).and_return(@players[0])
            @players[0].assign_kitty([@four_diamonds, @four_hearts, @five_spades]) # ai doesn't see these cards
            cards = @ai.request(:play)

            @ai.probabilities[3][@eight_spades.code].should == 0.0
            @ai.probabilities[0][@eight_spades.code].should == 13.0 / 33.0
            @ai.probabilities[:kitty][@eight_spades.code].should == 0.0
          end

          it "with a card from your hand" do
            card = @ai.request(:play)

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