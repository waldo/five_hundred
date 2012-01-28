# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "player" do
    include_context "game support"
    include_context "named cards"

    before(:each) do
      @player = Player.new
    end

    it "'s suits in hand are correct" do
      @player.assign_cards([@five_clubs, @nine_hearts, @joker])
      @player.suits_excluding_joker(:diamonds).should == [:clubs, :hearts, nil]
    end

    it "should be able to discard cards from both your hand and kitty" do
      @player.assign_cards([@queen_hearts, @jack_diamonds, @ace_spades, @seven_hearts, @nine_clubs, @ace_hearts, @king_hearts, @eight_hearts, @eight_diamonds, @ten_hearts])
      @player.assign_kitty([@five_clubs, @nine_hearts, @joker])

      cards_to_discard = [@nine_clubs, @five_clubs, @eight_diamonds]

      @player.remove_cards(cards_to_discard)
      @player.cards.count.should == 8
      @player.kitty.count.should == 2

      @player.merge_kitty
      @player.cards.count.should == 10
      @player.kitty.count.should == 0
    end
  end
end
