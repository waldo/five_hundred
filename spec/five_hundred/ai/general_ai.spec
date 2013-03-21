# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module AI
    describe "ai" do
      include_context "game support"
      include_context "named bids"
      include_context "named cards"

      before do
        @ai = GeneralAI.new

        players = Array.new(3) { Player.new }
        players += [@ai]

        build_game_stub(players)

        @round = double("Round").as_null_object
        @trick = double("Trick").as_null_object

        @game.stub(:current_round => @round)
        @card_arr = [@joker, @jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ten_hearts, @nine_hearts, @eight_hearts, @seven_hearts]
        @round.stub(
          :trump_suit => :hearts,
          :highest_bid => @bid_10d,
          :valid_bids => [@bid_10d, @bid_10h, @bid_om, @bid_10nt, @pass],
          :valid_cards => @card_arr,
          :current_trick => @trick
        )
        @trick.stub(
          :led_suit => :clubs,
          :max_rank => 6
        )

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

        context "play your highest card (the joker)" do
          it do
            @ai.request(:play).should == @joker
          end

          it "in misére or no trumps round" do
            @round.stub(:trump_suit).and_return(:none)

            @ai.request(:play).should == @joker
          end
        end
      end

      context "actions" do
        describe "play highest card" do
          subject { @ai.highest_card }

          it "returns your highest ranked card" do
            @round.stub(:valid_cards => [@jack_diamonds, @seven_hearts, @eight_clubs])

            should == @jack_diamonds
          end
        end

        describe "play lowest winner" do
          subject { @ai.lowest_winner }

          before do
            @round.stub(:valid_cards => [@jack_diamonds, @seven_hearts, @eight_clubs])
            @trick.stub(:max_rank => @ace_clubs.rank)
          end

          it "returns a winning card lower than your highest ranked" do
            should == @seven_hearts
          end

          it "returns a winning card even if it's your highest ranked" do
            @round.stub(:valid_cards => [@seven_hearts, @eight_clubs])

            should == @seven_hearts
          end
        end

        describe "play lowest trump" do
          subject { @ai.lowest_trump }

          before do
            @round.stub(:valid_cards => [@jack_diamonds, @seven_hearts, @eight_clubs])
          end

          it "returns your lowest trump" do
            should == @seven_hearts
          end
        end

        describe "play lowest card" do
          subject { @ai.lowest_card }

          context "multiple suits in valid choices including trumps" do
            it "plays lowest in the non-trump suit with fewest cards" do
              cards = [@seven_hearts, @eight_clubs, @seven_clubs, @eight_spades, @seven_spades, @six_spades]
              @ai.assign_cards(cards)
              @round.stub(:valid_cards => cards)

              should == @seven_clubs
            end
          end

          context "short of trumps (i.e. don't bother shorting if you don't have trumps)" do
            it "plays your lowest ranked card" do
              cards = [@eight_clubs, @seven_clubs, @eight_spades, @seven_spades, @six_spades]
              @ai.assign_cards(cards)
              @round.stub(:valid_cards => cards)

              should == @six_spades
            end
          end
        end
      end
    end
  end
end