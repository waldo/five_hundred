# encoding: UTF-8

module FiveHundred
  class Card
    attr_reader :code

    @@ace_rank = 14
    @@right_bower = 99
    @@left_bower = 98
    @@opposite_suits = {:spades => :clubs, :clubs => :spades, :diamonds => :hearts, :hearts => :diamonds}

    def initialize(code, rank, suit)
      @code = code
      @rank = rank
      @suit = suit
    end

    def rank_with_led(led_suit, trump_suit)
      return rank(trump_suit) if led_suit.nil?

      val = 0
      if [led_suit, trump_suit].include?(self.suit(trump_suit))
        val = rank(trump_suit)
      end

      val
    end

    def rank(trump_suit=nil)
      val = @rank
      if right_bower?(trump_suit)
        val = @@right_bower
      elsif left_bower?(trump_suit)
        val = @@left_bower
      elsif trump?(trump_suit) and !joker?
        val = @rank + @@ace_rank
      end

      val
    end

    def suit(trump_suit=nil)
      current_suit = @suit
      current_suit = @@opposite_suits[@suit] if left_bower?(trump_suit)
      current_suit = trump_suit if joker? && @suit == :none unless trump_suit.nil?
      current_suit
    end

    def set_joker_suit(suit)
      @suit = suit if joker?
      self
    end

    def joker?
      @code == "Jo"
    end

    def trump?(trump_suit)
      return false if [:none, :misere].include?(trump_suit)
      @suit == trump_suit or left_bower?(trump_suit) or right_bower?(trump_suit) or joker?
    end

    def right_bower?(trump_suit)
      @suit == trump_suit and @rank == 11
    end

    def left_bower?(trump_suit)
      bower_check(trump_suit, :spades, :clubs) or
      bower_check(trump_suit, :clubs, :spades) or
      bower_check(trump_suit, :diamonds, :hearts) or
      bower_check(trump_suit, :hearts, :diamonds)
    end

    def to_s
      "#{@code}"
    end

    def eql?(other)
      self.class.equal?(other.class) && self.to_s == other.to_s
    end

    alias == eql?

    def hash
      self.class.hash ^ self.to_s.hash
    end

    def bower_check(trump_suit, suit_a, suit_b)
      trump_suit == suit_a and @suit == suit_b and rank == 11
    end
    private :bower_check

    def joker_suit_variations
      variations = []
      if joker?
        [:spades, :clubs, :diamonds, :hearts].each do |suit|
          new_joker = self.clone
          variations << new_joker.set_joker_suit(suit)
        end
      end

      variations
    end
  end
end
