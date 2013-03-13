# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module RoundSets
    describe "trick" do
      include_context "named cards"

      before do
        @trick = Trick.new(:clubs)
        @players = Array.new(4) { double("Player").as_null_object }
      end

      def play_trick!(cards=[@six_clubs, @king_spades, @ace_clubs, @jack_spades])
        @players.each_with_index do |p, i|
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

        it "to the player who played the joker" do
          play_trick!([@six_spades, @five_clubs, @ace_spades, @joker])
          @trick.winner.should == @players[3]
        end

        it "to the highest card in the led suit ignoring higher non-led suit cards" do
          play_trick!([@six_spades, @king_spades, @ace_hearts, @nine_spades])
          @trick.winner.should == @players[1]
        end

        it "to the left and right bower" do
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

        it "ignoring bowers if no trumps of misere is the bid" do
          @trick = Trick.new(:none)
          play_trick!([@six_clubs, @king_spades, @ace_clubs, @jack_clubs])
          @trick.winner.should == @players[2]
        end
      end

      it "should not be assigned until complete" do
        @trick = Trick.new(:hearts)
        @trick.play(@six_clubs, @players[0])
        @trick.play(@king_spades, @players[1])
        @trick.play(@ace_clubs, @players[2])

        @trick.winner.class.should == NullObject
      end

      context "should not let a player play" do
        it "a card they don't have" do
          @players[0].stub(:has_card).and_return(false)

          @trick.valid_play?(@seven_clubs, @players[0]).should be_false
        end

        it "off suit if they have a card in the suit led" do
          @trick.play(@six_clubs, @players[0])
          @trick.valid_play?(@eight_diamonds, @players[1]).should be_false
        end
      end

      context "with left bower" do
        it "where spades is trumps, Jc should not be played as a club" do
          @trick = Trick.new(:spades)
          @trick.play(@six_clubs, @players[0])
          @trick.valid_play?(@jack_clubs, @players[2]).should be_false
        end

        it "where hearts is trumps and Jd is your last trump, Jd must be played" do
          @trick = Trick.new(:hearts)
          @trick.play(@six_hearts, @players[0])
          @players[2].stub(:cards) do Deck.cards(%w{9d 10s 10c 10d Js Jc Jd}) end

          @trick.valid_play?(@jack_spades, @players[2]).should be_false
          @trick.valid_play?(@jack_diamonds, @players[2]).should be_true
        end
      end

      context "with joker" do
        it "where spades is trumps, Jo should not be played as a club" do
          @trick = Trick.new(:spades)
          @trick.play(@six_clubs, @players[0])
          @trick.stub(:has_led_suit).and_return(true)

          @trick.valid_play?(@joker, @players[3]).should be_false
        end

        it "where trump suit is led and Jo is your last trump, Jo must be played" do
          @trick = Trick.new(:hearts)
          @trick.play(@six_hearts, @players[0])
          @players[3].stub(:cards) do Deck.cards(%w{Ks Kc Kd As Ac Ad Jo}) end

          @trick.valid_play?(@ace_diamonds, @players[3]).should be_false
          @trick.valid_play?(@joker, @players[3]).should be_true
        end

        it "where spades is trumps, Jo can be used to trump in" do
          @trick = Trick.new(:spades)
          @trick.play(@six_hearts, @players[0])
          @players[3].stub(:cards) do Deck.cards(%w{Ks Kc Kd As Ac Ad Jo}) end
          @players[3].stub(:suits).and_return([:spades, :clubs, :diamonds])
          @trick.valid_play?(@joker, @players[3]).should be_true
        end

        it "where Jo is led in NT, other players must follow suit" do
          @trick = Trick.new(:none)
          @trick.play(@joker.set_joker_suit(:hearts), @players[3])
          @trick.valid_play?(@five_clubs, @players[0]).should be_false
          @trick.valid_play?(@five_hearts, @players[0]).should be_true
        end
      end
    end
  end
end
