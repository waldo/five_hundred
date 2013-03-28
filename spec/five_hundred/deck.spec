# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "deck" do
    include_context "named cards"

    it "should create a card" do
      card = Deck.card("6s")
      card.code.should == "6s"
      card.rank[:none][nil].should == 6
      card.suit[:none].should == :spades
    end

    it "should create several cards" do
      cards = Deck.cards(["7s", "Jc"])
      cards.count.should == 2
      cards.should include(@seven_spades)
      cards.should include(@jack_clubs)
    end

    it "should create a deck with shuffled cards" do
      default_deck = Deck.set_of_cards
      shuffled_deck = Deck.new.cards

      count = 0

      default_deck.zip(shuffled_deck).each do |default_card, shuffled_card|
        count += 1 if default_card == shuffled_card
      end

      count.should_not == 43
    end

    it "should deal cards" do
      deck = Deck.new

      cards = deck.deal
      cards.count.should == 10

      deck.cards.count.should == 33

      cards.each do |c|
        deck.cards.should_not include(c)
      end
    end

    it "should have a set of cards" do
      deck = Deck.set_of_cards
      deck.count.should == 43
      deck.should include(@six_hearts)
      deck.should include(@joker)
    end
  end
end
