# encoding: UTF-8
require "spec_helper"

describe "trick should correctly assign the trick" do
  before(:each) do
    @trick = Trick.new(:clubs)
    @six_spades =     Deck.card("6s")
    @nine_spades =    Deck.card("9s")
    @king_spades =    Deck.card("Ks")
    @ace_spades =     Deck.card("As")
    @five_clubs =     Deck.card("5c")
    @six_clubs =      Deck.card("6c")
    @ace_clubs =      Deck.card("Ac")
    @joker =          Deck.card("Jo")
    @ace_hearts =     Deck.card("Ah")
    @jack_spades =    Deck.card("Js")
    @jack_clubs =     Deck.card("Jc")
    @six_hearts =     Deck.card("6h")
    @ace_hearts =     Deck.card("Ah")
    @jack_hearts =    Deck.card("Jh")
    @jack_diamonds =  Deck.card("Jd")

    @p0 = Player.new
    @p1 = Player.new
    @p2 = Player.new
    @p3 = Player.new
  end

  it "to the player with the highest card" do
    @trick.play(@six_spades, @p0)
    @trick.play(@king_spades, @p1)
    @trick.play(@ace_spades, @p2)
    @trick.play(@nine_spades, @p3)
    @trick.winner == @p2
  end
  
  it "if a player trumps in with the highest trump" do
    @trick.play(@six_spades, @p0)
    @trick.play(@five_clubs, @p1)
    @trick.play(@ace_spades, @p2)
    @trick.play(@nine_spades, @p3)
    @trick.winner.should == @p1

    @trick = Trick.new(:clubs)
    @trick.play(@six_spades, @p0)
    @trick.play(@five_clubs, @p1)
    @trick.play(@ace_spades, @p2)
    @trick.play(@six_clubs, @p3)
    @trick.winner.should == @p3
  end
  
  it "where Joker is the highest card" do
    @trick.play(@six_spades, @p0)
    @trick.play(@five_clubs, @p1)
    @trick.play(@ace_spades, @p2)
    @trick.play(@joker, @p3)
    @trick.winner.should == @p3
  end
  
  it "if a non-led suit is higher than a card in the led suit" do
    @trick.play(@six_spades, @p0)
    @trick.play(@king_spades, @p1)
    @trick.play(@ace_hearts, @p2)
    @trick.play(@nine_spades, @p3)
    @trick.winner.should == @p1
  end
  
  it "with a left and right bower" do
    @trick.play(@six_clubs, @p0)
    @trick.play(@king_spades, @p1)
    @trick.play(@ace_clubs, @p2)
    @trick.play(@jack_clubs, @p3)
    @trick.winner.should == @p3

    @trick = Trick.new(:clubs)
    @trick.play(@six_clubs, @p0)
    @trick.play(@king_spades, @p1)
    @trick.play(@ace_clubs, @p2)
    @trick.play(@jack_spades, @p3)
    @trick.winner.should == @p3

    @trick = Trick.new(:hearts)
    @trick.play(@six_hearts, @p0)
    @trick.play(@jack_diamonds, @p1)
    @trick.play(@ace_hearts, @p2)
    @trick.play(@jack_hearts, @p3)
    @trick.winner.should == @p3

    @trick = Trick.new(:hearts)
    @trick.play(@six_hearts, @p0)
    @trick.play(@jack_diamonds, @p1)
    @trick.play(@ace_hearts, @p2)
    @trick.play(@jack_spades, @p3)
    @trick.winner.should == @p1
  end

  it "with no bowers if NT or misere is bid" do
    @trick = Trick.new(:none)
    @trick.play(@six_clubs, @p0)
    @trick.play(@king_spades, @p1)
    @trick.play(@ace_clubs, @p2)
    @trick.play(@jack_clubs, @p3)
    @trick.winner.should == @p2
  end
end
