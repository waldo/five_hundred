# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "trick" do
    include_context "game support"
    include_context "named cards"

    before(:each) do
      @trick = Trick.new(:clubs)
    end

    def play_trick!(cards=[@six_clubs, @king_spades, @ace_clubs, @jack_spades])
      @players.each_with_index do |p,i|
        @trick.play(cards[i], p)
      end
    end

    context "should be assigned" do
      it "to the player with the highest card" do
        play_trick!([@six_spades, @king_spades, @ace_spades, @nine_spades])
        @trick.winner.should == @players[2]
      end
  
      it "if a player trumps in with the highest trump" do
        play_trick!([@six_spades, @five_clubs, @ace_spades, @nine_spades])
        @trick.winner.should == @players[1]

        @trick = Trick.new(:clubs)
        play_trick!([@six_spades, @five_clubs, @ace_spades, @six_clubs])
        @trick.winner.should == @players[3]
      end
  
      it "where Joker is the highest card" do
        play_trick!([@six_spades, @five_clubs, @ace_spades, @joker])
        @trick.winner.should == @players[3]
      end
  
      it "if a non-led suit is higher than a card in the led suit" do
        play_trick!([@six_spades, @king_spades, @ace_hearts, @nine_spades])
        @trick.winner.should == @players[1]
      end
  
      it "with a left and right bower" do
        play_trick!([@six_clubs, @king_spades, @ace_clubs, @jack_clubs])
        @trick.winner.should == @players[3]

        @trick = Trick.new(:clubs)
        play_trick!([@six_clubs, @king_spades, @ace_clubs, @jack_spades])
        @trick.winner.should == @players[3]

        @trick = Trick.new(:hearts)
        play_trick!([@six_hearts, @jack_diamonds, @ace_hearts, @jack_hearts])
        @trick.winner.should == @players[3]

        @trick = Trick.new(:hearts)
        play_trick!([@six_hearts, @jack_diamonds, @ace_hearts, @jack_spades])
        @trick.winner.should == @players[1]
      end

      it "with no bowers if NT or misere is bid" do
        @trick = Trick.new(:none)
        play_trick!([@six_clubs, @king_spades, @ace_clubs, @jack_clubs])
        @trick.winner.should == @players[2]
      end
    end

    context "should not let a player play " do
      it "a card they don't have" do
        @trick.valid_play?(@seven_clubs, @players[0]).should == false
      end

      it "off suit if they have a card in the suit led" do
        @trick.play(@six_clubs, @players[0])
        @trick.valid_play?(@eight_diamonds, @players[1]).should == false
      end
    end
  
    context "with left bower" do
      it "where spades is trumps, Jc should not be played as a club" do
        @trick = Trick.new(:spades)
        @trick.play(@six_clubs, @players[0])
        @trick.valid_play?(@jack_clubs, @players[2]).should == false
      end
    
      it "where hearts is trumps and Jd is your last trump, Jd must be played" do
        @trick = Trick.new(:hearts)
        @trick.play(@six_hearts, @players[0])
        @players[2].stub(:cards) do Deck.cards(%w{9d 10s 10c 10d Js Jc Jd}) end
        @trick.valid_play?(@jack_spades, @players[2]).should == false      
        @trick.valid_play?(@jack_diamonds, @players[2]).should == true
      end
    end

    context "with joker" do
      it "where spades is trumps, Jo should not be played as a club" do
        @trick = Trick.new(:spades)
        @trick.play(@six_clubs, @players[0])
        @trick.valid_play?(@joker, @players[3]).should == false
      end
    
      it "where trump suit is led and Jo is your last trump, Jo must be played" do
        @trick = Trick.new(:hearts)
        @trick.play(@six_hearts, @players[0])
        @players[3].stub(:cards) do Deck.cards(%w{Ks Kc Kd As Ac Ad Jo}) end
        @trick.valid_play?(@ace_diamonds, @players[3]).should == false
        @trick.valid_play?(@joker, @players[3]).should == true
      end

      it "where spades is trumps, Jo can be used to trump in" do
        @trick = Trick.new(:spades)
        @trick.play(@six_hearts, @players[0])
        @players[3].stub(:cards) do Deck.cards(%w{Ks Kc Kd As Ac Ad Jo}) end
        @trick.valid_play?(@joker, @players[3]).should == true
      end
    
      it "where Jo is led in NT, other players must follow suit" do
        @trick = Trick.new(:none)
        @trick.play(@joker.set_joker_suit(:hearts), @players[3])
        @trick.valid_play?(@five_clubs, @players[0]).should == false
        @trick.valid_play?(@five_hearts, @players[0]).should == true
      end
    
      it "suit must be specified if leading with Jo for NT or misere" do
        @trick = Trick.new(:none)
        @trick.valid_play?(@joker, @players[3]).should == false
        @trick.valid_play?(@joker.set_joker_suit(:clubs), @players[3]).should == true
      end
    end
  end
end