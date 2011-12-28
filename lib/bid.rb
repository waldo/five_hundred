class Bid
  attr_reader :code, :suit

  def initialize(code)
    @code = code
    @suit = Bid.all[code][:suit]
  end

  def >(other_bid)
    return true if other_bid.nil?

    if self.code == "cm" and !Bid.all["cm"][:precondition].include?(other_bid.code)
      return false
    end

    Bid.all.keys.index(self.code) > Bid.all.keys.index(other_bid.code)
  end

  def passed?
    @code == "pass"
  end

  def max_bid?
    @code == "10nt"
  end

  def to_s
    @code
  end

  def ==(other)
    @code == other.code
  end

# class
  class << self; attr_accessor :all end
  
  @all = {
    "6s"    => {points:   40, suit: :spades},
    "6c"    => {points:   60, suit: :clubs},
    "6d"    => {points:   80, suit: :diamonds},
    "6h"    => {points:  100, suit: :hearts},
    "6nt"   => {points:  120, suit: :none},
    "7s"    => {points:  140, suit: :spades},
    "7c"    => {points:  160, suit: :clubs},
    "7d"    => {points:  180, suit: :diamonds},
    "7h"    => {points:  200, suit: :hearts},
    "7nt"   => {points:  220, suit: :none},
    "cm"    => {precondition:  ["7s","7c","7d","7h","7nt"], points:  250, suit: :misere},
    "8s"    => {points:  240, suit: :spades},
    "8c"    => {points:  260, suit: :clubs},
    "8d"    => {points:  280, suit: :diamonds},
    "8h"    => {points:  300, suit: :hearts},
    "8nt"   => {points:  320, suit: :none},
    "9s"    => {points:  340, suit: :spades},
    "9c"    => {points:  360, suit: :clubs},
    "9d"    => {points:  380, suit: :diamonds},
    "9h"    => {points:  400, suit: :hearts},
    "9nt"   => {points:  420, suit: :none},
    "10s"   => {points:  440, suit: :spades},
    "10c"   => {points:  460, suit: :clubs},
    "10d"   => {points:  480, suit: :diamonds},
    "10h"   => {points:  500, suit: :hearts},
    "om"    => {points:  500, suit: :misere},
    "10nt"  => {points:  520, suit: :none},
    "pass"  => {pass: true, suit: :none},
  }

  def self.empty
    empty = NullObject.new
    mod = Module.new do
      def >(bid)
        false
      end
      def passed?
        false
      end
      def max_bid?
        false
      end
    end
    empty.extend(mod)
  end
end