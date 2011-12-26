# encoding: UTF-8
require "spec_helper"

describe "trick should correctly assign the trick" do
  before(:each) do
    @trick = Trick.new(:clubs)
    @six_spades = Deck.create_card("6s")
    @nine_spades = Deck.create_card("9s")
    @king_spades = Deck.create_card("Ks")
    @ace_spades = Deck.create_card("As")
    @five_clubs = Deck.create_card("5c")
    @six_clubs = Deck.create_card("6c")
    @ace_clubs = Deck.create_card("Ac")
    @joker = Deck.create_card("Jo")
    @ace_hearts = Deck.create_card("Ah")
    @jack_spades = Deck.create_card("Js")
    @jack_clubs = Deck.create_card("Jc")
    @six_hearts = Deck.create_card("6h")
    @ace_hearts = Deck.create_card("Ah")
    @jack_hearts = Deck.create_card("Jh")
    @jack_diamonds = Deck.create_card("Jd")
  end

  it "to the player with the highest card" do
    @trick.play(@six_spades)
    @trick.play(@king_spades)
    @trick.play(@ace_spades)
    @trick.play(@nine_spades)
    @trick.winning_position.should == 2
  end
  
  it "if a player trumps in with the highest trump" do
    @trick.play(@six_spades)
    @trick.play(@five_clubs)
    @trick.play(@ace_spades)
    @trick.play(@nine_spades)
    @trick.winning_position.should == 1

    @trick = Trick.new(:clubs)
    @trick.play(@six_spades)
    @trick.play(@five_clubs)
    @trick.play(@ace_spades)
    @trick.play(@six_clubs)
    @trick.winning_position.should == 3
  end
  
  it "where Joker is the highest card" do
    @trick.play(@six_spades)
    @trick.play(@five_clubs)
    @trick.play(@ace_spades)
    @trick.play(@joker)
    @trick.winning_position.should == 3
  end
  
  it "if a non-led suit is higher than a card in the led suit" do
    @trick.play(@six_spades)
    @trick.play(@king_spades)
    @trick.play(@ace_hearts)
    @trick.play(@nine_spades)
    @trick.winning_position.should == 1
  end
  
  it "with a left and right bower" do
    @trick.play(@six_clubs)
    @trick.play(@king_spades)
    @trick.play(@ace_clubs)
    @trick.play(@jack_clubs)
    @trick.winning_position.should == 3

    @trick = Trick.new(:clubs)
    @trick.play(@six_clubs)
    @trick.play(@king_spades)
    @trick.play(@ace_clubs)
    @trick.play(@jack_spades)
    @trick.winning_position.should == 3

    @trick = Trick.new(:hearts)
    @trick.play(@six_hearts)
    @trick.play(@jack_diamonds)
    @trick.play(@ace_hearts)
    @trick.play(@jack_hearts)
    @trick.winning_position.should == 3

    @trick = Trick.new(:hearts)
    @trick.play(@six_hearts)
    @trick.play(@jack_diamonds)
    @trick.play(@ace_hearts)
    @trick.play(@jack_spades)
    @trick.winning_position.should == 1
  end

  it "with no bowers if NT or misere is bid" do
    @trick = Trick.new(:none)
    @trick.play(@six_clubs)
    @trick.play(@king_spades)
    @trick.play(@ace_clubs)
    @trick.play(@jack_clubs)
    @trick.winning_position.should == 2
  end
end
