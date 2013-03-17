# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module RoundSets
    describe "trick set" do
      include_context "game support"
      include_context "named cards"

      def play!(cards)
        cards = (cards.respond_to?(:each) ? cards : [cards])
        cards.each {|c| @trick_set.play!(c)}
      end

      before do
        @players = Array.new(4) { double("Player").as_null_object }
        @trick_set = TrickSet.new(:hearts, @players.dup)
      end

      it "should check if the played card is valid" do
        @players[0].stub(:has_card).and_return(false)
        @trick_set.valid_play?(@queen_hearts).should be_false

        @players[0].stub(:has_card).and_return(true)
        @trick_set.valid_play?(@six_hearts).should be_true
      end

      it "should play a card" do
        @trick_set.current_trick.should_receive(:play).with(@six_spades, @players[0])

        @trick_set.play(@six_spades)
      end

      it "should move to the next player" do
        play!(@six_spades)
        @trick_set.current_player.should == @players[1]

        play!(@eight_spades)
        @trick_set.current_player.should == @players[2]
      end

      it "should record trick winner at the end of a trick" do
        play!(@six_spades)
        play!(@eight_spades)
        play!(@ten_spades)
        play!(@ace_spades)

        @trick_set.tricks_won(@players[3].team).should == 1
      end

      it "should have bid winner play the first card of the trick" do
        @trick_set = TrickSet.new(:hearts, @players.dup.rotate!)
        @trick_set.current_player.should == @players[1]
      end

      it "should have trick winner play the first card of next trick" do
        play!(@six_spades)
        play!(@eight_spades)
        play!(@joker)
        play!(@ace_spades)

        @trick_set.current_player.should == @players[2]
      end

      it "should start a new trick after 4 cards are played" do
        @trick_set.should_receive(:next_trick!).once

        play!(@six_spades)
        play!(@eight_spades)
        play!(@joker)
        play!(@ace_spades)
      end

      it "should end round after 10 tricks" do
        10.times do
          play!(@eight_clubs)
          play!(@eight_diamonds)
          play!(@eight_hearts)
          play!(@eight_spades)
        end

        @trick_set.complete?.should be_true
      end

      context "playing misere" do
        before do
          @trick_set = TrickSet.new(:misere, @players.dup)
        end

        it "should ensure the misere bidder's partner is skipped" do
          @trick_set.current_player.should == @players[0]
          play!(@seven_diamonds)
          @trick_set.current_player.should == @players[1]
          play!(@nine_diamonds)
          @trick_set.current_player.should == @players[3]
          play!(@nine_hearts)
        end

        it "should start a new trick after 3 cards are played for misere" do
          @trick_set.should_receive(:next_trick!).once

          play!(@six_spades)
          play!(@eight_spades)
          play!(@joker)
        end

        it "should end trick set if misere bidder wins a trick" do
          play!(@queen_spades)
          play!(@eight_spades)
          play!(@eight_diamonds)

          @trick_set.complete?.should be_true
        end
      end

      context "playing joker in NT or misere" do
        before do
          @trick_set = TrickSet.new(:none, @players.dup)
        end

        it "shouldn't check if the joker is ok unless card is a joker" do
          @trick_set.stub(:valid_joker?).and_return(false)
          @trick_set.joker_rules?(@six_spades).should be_true
          @trick_set.joker_rules?(@joker).should be_false
        end

        it "suit must be specified if led" do
          @trick_set.joker_rules?(@joker).should be_false
          @trick_set.joker_rules?(@joker.set_joker_suit(:clubs)).should be_true
        end

        it "should auto convert joker where sensible" do
          play!(@four_hearts)

          @trick_set.joker_rules?(@joker).should be_true
        end

        it "shouldn't allow as second card in suit" do
          @trick_set.stub(:first_play_of_suit?).and_return(false)
          @trick_set.stub(:none_remaining_in_suit?).and_return(false)

          @trick_set.joker_rules?(@joker.set_joker_suit(:hearts)).should be_false
        end

        it "as last card in suit" do
          @trick_set.stub(:first_play_of_suit?).and_return(false)
          @trick_set.stub(:none_remaining_in_suit?).and_return(true)

          @trick_set.joker_rules?(@joker.set_joker_suit(:hearts)).should be_true
        end

        it "shouldn't allow after declaring suit void" do
          @trick_set.stub(:first_play_of_suit?).and_return(false)
          @trick_set.stub(:none_remaining_in_suit?).and_return(true)
          @trick_set.stub(:unvoided_suit?).and_return(false)

          @trick_set.joker_rules?(@joker.set_joker_suit(:hearts)).should be_false
        end
      end

      context "should determine" do
        before do
          @trick_set = TrickSet.new(:none, @players.dup)
        end

        it "played cards correctly for a player" do
          play!(@four_hearts)
          play!(@seven_hearts)
          play!(@nine_hearts)
          play!(@queen_hearts)

          play!(@ace_diamonds)
          play!(@four_diamonds)
          play!(@seven_diamonds)
          play!(@nine_diamonds)

          @trick_set.played_cards(@players[0]).count.should == 2
          @trick_set.played_cards(@players[0]).should == [@four_hearts, @four_diamonds]
        end

        it "played suits correctly for a player" do
          play!([@four_hearts, @seven_hearts, @nine_hearts, @queen_hearts])
          play!([@ace_diamonds, @four_diamonds, @seven_diamonds, @nine_diamonds])
          @trick_set.send(:played_suits, @players[0]).should include(:hearts)
          @trick_set.send(:played_suits, @players[0]).should include(:diamonds)
        end

        it "voided suits correctly for a player" do
          play!([@five_clubs, @seven_clubs, @ten_clubs, @queen_hearts])
          @trick_set.send(:voided_suits, @players[3]).should include(:clubs)

          play!([@nine_hearts, @king_diamonds, @four_hearts, @seven_hearts])
          @trick_set.send(:voided_suits, @players[3]).should include(:hearts)
        end
      end

      context "valid cards" do
        before do
          @trick_set = TrickSet.new(:none, @players.dup)
        end

        it "should accept joker as a player's second trump card" do
          @trick_set = TrickSet.new(:hearts, @players.dup)
          @trick_set.stub(:current_player).and_return(@players[0])
          @players[0].stub(:cards) do Deck.cards(%w{Jd Qh Jo}) end
          @players[1].stub(:cards) do Deck.cards(%w{8h 9c 7c}) end
          @players[2].stub(:cards) do Deck.cards(%w{9h 5c Jc}) end
          @players[3].stub(:cards) do Deck.cards(%w{10h 6c Ks}) end

          @trick_set.valid_cards.should == [@joker, @jack_diamonds, @queen_hearts]

          play!([@jack_diamonds, @eight_hearts, @nine_hearts, @ten_hearts])

          @players[0].stub(:cards) do Deck.cards(%w{Qh Jo}) end
          @trick_set.valid_cards.should == [@joker, @queen_hearts]
        end

        it "should accept joker with the right suit" do
          @trick_set.play(@four_hearts)
          @trick_set.stub(:current_player).and_return(@players[1])
          @players[1].stub(:cards) do Deck.cards(%w{Qh Ks Kd As Ad Jo}) end

          @trick_set.valid_cards.should == [
            @joker,
            @queen_hearts,
          ]

          @trick_set.valid_cards.map {|c| c.suit(@trick_set.trump_suit) }.should == [:hearts, :hearts]
        end

        it "should offer 4 joker suit selection as valid cards when leading (as suit is not implied)" do
          @players[0].stub(:cards) do Deck.cards(%w{Ks Kd As Ad Jo}) end

          @trick_set.valid_cards.should == [
            @joker.joker_suit_variations,
            @ace_diamonds,
            @ace_spades,
            @king_diamonds,
            @king_spades,
          ].flatten
        end
      end

      context "report" do
        it "provides a list of the remaining highest ranked cards" do
          cards = [
            [@jack_diamonds, @eight_hearts, @nine_spades, @ten_clubs],
            [@jack_hearts, @eight_spades, @nine_clubs, @ten_diamonds],
            [@jack_spades, @eight_clubs, @nine_diamonds, @ten_hearts],
            [@jack_clubs, @eight_diamonds, @nine_hearts, @ten_spades],
          ]

          cards.each do |trick_cards|
            play!(trick_cards)
          end

          @trick_set.remaining_cards.first.should == @joker
          @trick_set.remaining_cards.should_not include(cards.flatten)
          @trick_set.remaining_cards.last.should == @four_diamonds
        end
      end
    end
  end
end
