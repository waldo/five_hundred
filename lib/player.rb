class Player
  attr_reader :bids, :cards

  def initialize
    @cards = []
    @bids = []
  end

  def assign_cards(cards)
    @cards += cards
  end
  
  def remove_cards(cards)
    @cards -= cards
  end

  def assign_bid(bid)
    @bids << bid
  end

  def passed?
    @bids.last.passed? if @bids.count > 0
  end

# class
  def self.empty
    NullObject.new
  end
end