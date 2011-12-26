# encoding: UTF-8
require "spec_helper"

describe "deck" do
  it "create cards" do
    card = Deck.card("6s")
    card.code.should == "6s"
    card.rank.should == 6
    card.suit.should == :spades
  end
end