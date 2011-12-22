class Player
  attr_reader :cards

  def initialize
    @cards = []
  end

  def assign_cards(cards)
    @cards = cards
  end
end