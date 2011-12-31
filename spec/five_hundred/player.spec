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
  end
end