class Bid
  attr_reader :code

  def initialize(code)
    @code = code
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

# class
  class << self; attr_accessor :all end
  
  @all = {
    "6s"    => {points:   40},
    "6c"    => {points:   60},
    "6d"    => {points:   80},
    "6h"    => {points:  100},
    "6nt"   => {points:  120},
    "7s"    => {points:  140},
    "7c"    => {points:  160},
    "7d"    => {points:  180},
    "7h"    => {points:  200},
    "7nt"   => {points:  220},
    "cm"    => {precondition:  ["7s","7c","7d","7h","7nt"], points:  250},
    "8s"    => {points:  240},
    "8c"    => {points:  260},
    "8d"    => {points:  280},
    "8h"    => {points:  300},
    "8nt"   => {points:  320},
    "9s"    => {points:  340},
    "9c"    => {points:  360},
    "9d"    => {points:  380},
    "9h"    => {points:  400},
    "9nt"   => {points:  420},
    "10s"   => {points:  440},
    "10c"   => {points:  460},
    "10d"   => {points:  480},
    "10h"   => {points:  500},
    "om"    => {points:  500},
    "10nt"  => {points:  520},
    "pass"  => true,
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