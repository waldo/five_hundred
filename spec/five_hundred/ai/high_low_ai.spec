# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module AI
    describe "ai" do
      include_context "game support"
      include_context "named bids"
      include_context "named cards"

      before do
        build_game_stub
        @round = double("Round").as_null_object
        @ai = HighLowAI.new

        @game.stub(:current_round).and_return(@round)
        @round.stub(:trump_suit).and_return(:hearts)
        @card_arr = [@jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @queen_clubs, @six_spades]
        @round.stub(:valid_cards).and_return(@card_arr)

        @ai.game = @game
        @ai.assign_cards(@card_arr)
      end

      context "should respond to requests for" do
        context "play" do
          context "given you have the highest card" do
            it "returns your highest card" do
              @round.stub(:remaining_cards).and_return(@card_arr)
              @ai.request(:play).should == @jack_hearts
            end
          end

          context "given you don't have the highest card" do
            it "returns your lowest valid card" do
              @round.stub(:remaining_cards).and_return([@joker] + @card_arr)
              @ai.request(:play).should == @six_spades
            end
          end
        end
      end
    end
  end
end
