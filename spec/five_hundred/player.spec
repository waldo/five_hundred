# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "player" do
    include_context "game support"
    include_context "named cards"

    before(:each) do
      @player = Player.new
    end

    it "'s cards are cleared on new deal" do
      @player.assign_cards([@queen_hearts, @jack_diamonds, @ace_spades, @seven_hearts, @nine_clubs, @ace_hearts, @king_hearts, @eight_hearts, @eight_diamonds, @ten_hearts])
      @player.assign_kitty([@five_clubs, @nine_hearts, @joker])
      @player.cards.count.should == 10
      @player.kitty.count.should == 3

      @player.assign_cards([@queen_hearts])

      @player.cards.count.should == 1
      @player.kitty.count.should == 0
    end

    it "'s suits in hand are correct" do
      @player.assign_cards([@five_clubs, @nine_hearts, @joker])
      @player.suits_excluding_joker(:diamonds).should == [:clubs, :hearts]
    end

    it "should be able to discard cards from both your hand and kitty" do
      @player.assign_cards([@queen_hearts, @jack_diamonds, @ace_spades, @seven_hearts, @nine_clubs, @ace_hearts, @king_hearts, @eight_hearts, @eight_diamonds, @ten_hearts])
      @player.assign_kitty([@five_clubs, @nine_hearts, @joker])

      cards_to_discard = [@nine_clubs, @five_clubs, @eight_diamonds]

      @player.discard_kitty(cards_to_discard)
      @player.cards.count.should == 10
      @player.kitty.count.should == 0
      @player.discarded_kitty.count.should == 3
    end

    it "should be able to discard / play a card" do
      @player.assign_cards([@queen_hearts, @jack_diamonds, @ace_spades, @seven_hearts, @nine_clubs, @ace_hearts, @king_hearts, @eight_hearts, @eight_diamonds, @ten_hearts])
      @player.remove_card(@queen_hearts)

      @player.cards.count.should == 9
    end
  end
end
