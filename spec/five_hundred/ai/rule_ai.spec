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
          @round.stub(:valid_cards => [@seven_hearts])

          @ai.one_valid_choice?.should be_true
        end

        it "returns false when multiple cards are valid" do
          @round.stub(:valid_cards => [@seven_hearts, @six_spades, @six_clubs])

          @ai.one_valid_choice?.should be_false
        end
      end

      describe "guaranteed winner" do
        before do
          @round.stub(:remaining_cards => [@jack_hearts, @jack_diamonds, @seven_hearts, @six_hearts])
        end

        it "returns true if the set includes the strongest remaining card" do
          @round.stub(:valid_cards => [@jack_hearts, @seven_hearts])

          @ai.guaranteed_winner?.should be_true
        end

        it "returns false if the set doesn't include the strongest remaining card" do
          @round.stub(:valid_cards => [@jack_diamonds, @seven_hearts])

          @ai.guaranteed_winner?.should be_false
        end
      end

      describe "highest in a non-trump suit" do
        it "returns each highest non-trump card that I have" do
          @ai.assign_cards([@ace_clubs, @king_diamonds, @king_clubs, @joker, @king_spades])

          @round.stub(:remaining_cards).with(:spades).and_return([@king_spades])
          @round.stub(:remaining_cards).with(:clubs).and_return([@ace_clubs])
          @round.stub(:remaining_cards).with(:diamonds).and_return([@ace_diamonds])

          @round.should_not_receive(:remaining_cards).with(:hearts)
          @ai.top_cards_non_trump_suit.should == [@king_spades, @ace_clubs]
        end

        it "returns empty array if I don't have any high cards" do
          @ai.assign_cards([@queen_clubs, @king_diamonds, @king_clubs, @joker, @jack_spades])

          @round.stub(:remaining_cards).with(:spades).and_return([@king_spades])
          @round.stub(:remaining_cards).with(:clubs).and_return([@ace_clubs])
          @round.stub(:remaining_cards).with(:diamonds).and_return([@ace_diamonds])

          @round.should_not_receive(:remaining_cards).with(:hearts)
          @ai.top_cards_non_trump_suit.should == []
        end
      end

      describe "guess if a player has this suit" do
        it "returns false if other team has voided this suit" do
          @round.stub(:voided_suits).with(@players[0]).and_return([:clubs, :spades])

          @ai.guess_player_has_suit?(@players[0], :clubs).should be_false
        end

        context "other played hasn't voided this suit" do
          before do
            @round.stub(:voided_suits).with(@players[0]).and_return([:spades])
            @round.stub(:remaining_cards).with(:clubs).and_return([@ace_clubs, @king_clubs, @queen_clubs, @jack_clubs, @ten_clubs])
          end

          it "returns false if 3 or less cards in this suit remain in unknown positions" do
            @ai.assign_cards([@ace_clubs, @king_clubs])

            @ai.guess_player_has_suit?(@players[0], :clubs).should be_false
          end

          it "returns true if 4 or more cards in this suit remain in unknown positions" do
            @ai.assign_cards([@ace_clubs])

            @ai.guess_player_has_suit?(@players[0], :clubs).should be_true
          end
        end
      end

# actions
      describe "play highest card in a suit" do
      end

      describe "play highest card" do
      end

      describe "play lowest winner" do
      end

      describe "trump high" do
      end

      describe "trump low" do
      end

      describe "play low" do
        it "plays lowest in led suit"
        it "plays lowest in the non-trump suit with fewest cards if you have trumps"
        it "plays your lowest ranked card"
      end
    end
  end
end
