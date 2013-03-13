# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "card" do
    include_context "named cards"

    before do
      @bowers = [@jack_spades, @jack_clubs, @jack_diamonds, @jack_hearts]
      @bower_original_suit = [:spades, :clubs, :diamonds, :hearts]
    end

    it "should initialize" do
      card = Card.new("6s", 6, :spades)

      card.code.should == "6s"
      card.suit.should == :spades
      card.rank.should == 6
    end

    context "joker" do
      it "should know it's the joker" do
        @joker.joker?.should be_true
        @six_hearts.joker?.should be_false
      end

      it "should allow suit override" do
        card = @joker
        card.set_joker_suit(:spades)
        card.suit.should == :spades

        other_card = @queen_diamonds
        other_card.set_joker_suit(:spades)
        other_card.suit.should_not == :spades
      end

      it "should have four suit variations of itself" do
        variations = @joker.joker_suit_variations
        variations.map(&:suit).should == [:spades, :clubs, :diamonds, :hearts]
      end
    end

    context "should recognise bowers" do
      it "- right" do
        @bower_original_suit.each_with_index do |ts, i|
          @bowers[i].right_bower?(ts).should be_true
        end
      end

      it "- left" do
        [:clubs, :spades, :hearts, :diamonds].each_with_index do |ts, i|
          @bowers[i].left_bower?(ts).should be_true
        end
      end

      it "- no bowers for misére or no-trumps" do
        @bowers.each do |b|
          b.right_bower?(:none).should be_false
          b.right_bower?(:misere).should be_false

          b.left_bower?(:none).should be_false
          b.left_bower?(:misere).should be_false
        end
      end
    end

    it "should know trumps" do
      @six_hearts.trump?(:hearts).should be_true
      @six_hearts.trump?(:spades).should be_false
      @jack_hearts.trump?(:hearts).should be_true
      @jack_diamonds.trump?(:hearts).should be_true
      @jack_diamonds.trump?(:spades).should be_false
    end

    context "recognise suits" do
      it "- normal" do
        @six_hearts.suit(:spades).should == :hearts
        @six_hearts.suit(:hearts).should == :hearts
        @six_hearts.suit(:clubs).should_not == :clubs
      end

      it "- bowers" do
        [:clubs, :spades, :hearts, :diamonds].each_with_index do |ts, i|
          @bowers[i].suit(ts).should == ts
        end

        @bower_original_suit.each_with_index do |ts, i|
          @bowers[i].suit(ts).should == ts
        end
      end

      it "- joker" do
        @joker.suit.should == :none
        @joker.suit(:diamonds).should == :diamonds
      end

      it "- bowers should be normal under no trumps or misére" do
        @bowers.each_with_index do |b, i|
          b.suit(:none).should == @bower_original_suit[i]
          b.suit(:misere).should == @bower_original_suit[i]
        end
      end
    end

    context "rank" do
      it "- normal" do
        @ace_diamonds.rank.should == 14
      end

      it "- trump" do
        @ace_diamonds.rank(:diamonds).should == 28
      end

      it "- bowers" do
        @jack_spades.rank(:spades).should == 99
        @jack_spades.rank(:clubs).should == 98
      end

      it "- joker" do
        @joker.rank.should == 100
      end

      it "- bowers should be normal under no trumps or misére" do
        @jack_spades.rank(:none).should == 11
        @jack_spades.rank(:misere).should == 11
      end

      context "given led suit" do
        it "- led suit" do
          @ace_diamonds.rank_with_led(:diamonds, :spades).should == 14
        end

        it "- trumps" do
          @ace_diamonds.rank_with_led(:diamonds, :diamonds).should == 28
          @ace_diamonds.rank_with_led(:spades, :diamonds).should == 28
        end

        it "- other" do
          @ace_diamonds.rank_with_led(:spades, :hearts).should == 0
        end
      end
    end
  end
end
