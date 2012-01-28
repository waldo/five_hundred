# encoding: UTF-8

module FiveHundred
  class Bid
    attr_reader :code, :suit

    def initialize(code)
      b = Bid.all[code]

      @code =             code
      @suit =             b[:suit]
      @tricks_required =  b[:tricks_required]
      @points =           b[:points]
    end

    def >(other_bid)
      if self.code == "cm" and !Bid.all["cm"][:precondition].include?(other_bid.code)
        return false
      end

      Bid.all.keys.index(self.code) > Bid.all.keys.index(other_bid.code)
    end

    def score_with(tricks, role=:bidder)
      pts = score_non_bidder(tricks)
      pts = score_bidder(tricks) if role == :bidder
      pts
    end

    def score_non_bidder(tricks)
      pts = 0
      pts = tricks * 10 if !misere?
      pts
    end
    private :score_non_bidder

    def score_bidder(tricks)
      pts = -@points
      pts = @points if bid_achieved?(tricks)
      pts = Bid.slam_points if tricks == 10 and @points < Bid.slam_points
      pts
    end
    private :score_bidder

    def bid_achieved?(tricks)
      achieved_misere?(tricks) or achieved_normal?(tricks)
    end

    def achieved_misere?(tricks)
      misere? and tricks == 0
    end
    private :achieved_misere?

    def achieved_normal?(tricks)
      !misere? and tricks >= @tricks_required
    end
    private :achieved_normal?

    def empty?
      @code == "empty"
    end

    def passed?
      @code == "pass"
    end

    def max_bid?
      @code == "10nt"
    end

    def misere?
      @suit == :misere
    end

    def to_s
      @code
    end

    def ==(other)
      @code == other.code
    end

  # class
    class << self; attr_accessor :slam_points, :all end

    @slam_points = 250

    @all = {
      "empty" => { tricks_required:  0, points:   0, suit: :none },
      "6s"    => { tricks_required:  6, points:   40, suit: :spades },
      "6c"    => { tricks_required:  6, points:   60, suit: :clubs },
      "6d"    => { tricks_required:  6, points:   80, suit: :diamonds },
      "6h"    => { tricks_required:  6, points:  100, suit: :hearts },
      "6nt"   => { tricks_required:  6, points:  120, suit: :none },
      "7s"    => { tricks_required:  7, points:  140, suit: :spades },
      "7c"    => { tricks_required:  7, points:  160, suit: :clubs },
      "7d"    => { tricks_required:  7, points:  180, suit: :diamonds },
      "7h"    => { tricks_required:  7, points:  200, suit: :hearts },
      "7nt"   => { tricks_required:  7, points:  220, suit: :none },
      "cm"    => { tricks_required:  0, points:  250, suit: :misere, precondition: ["7s","7c","7d","7h","7nt"] },
      "8s"    => { tricks_required:  8, points:  240, suit: :spades },
      "8c"    => { tricks_required:  8, points:  260, suit: :clubs },
      "8d"    => { tricks_required:  8, points:  280, suit: :diamonds },
      "8h"    => { tricks_required:  8, points:  300, suit: :hearts },
      "8nt"   => { tricks_required:  8, points:  320, suit: :none },
      "9s"    => { tricks_required:  9, points:  340, suit: :spades },
      "9c"    => { tricks_required:  9, points:  360, suit: :clubs },
      "9d"    => { tricks_required:  9, points:  380, suit: :diamonds },
      "9h"    => { tricks_required:  9, points:  400, suit: :hearts },
      "9nt"   => { tricks_required:  9, points:  420, suit: :none },
      "10s"   => { tricks_required: 10, points:  440, suit: :spades },
      "10c"   => { tricks_required: 10, points:  460, suit: :clubs },
      "10d"   => { tricks_required: 10, points:  480, suit: :diamonds },
      "10h"   => { tricks_required: 10, points:  500, suit: :hearts },
      "om"    => { tricks_required:  0, points:  500, suit: :misere },
      "10nt"  => { tricks_required: 10, points:  520, suit: :none },
      "pass"  => { tricks_required:  0, points:    0, suit: :none, pass: true },
    }

    def self.all_bids
      Bid.all.map {|key, val| Bid.new(key) }
    end
  end
end
