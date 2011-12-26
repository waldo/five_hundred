class Trick
  def initialize(trump_suit)
    @trump_suit = trump_suit
    @cards = []
  end

  def play(card)
    @cards.push(card)
  end
  
  def winning_position
    max_card = @cards.max_by do |c|
      c.card_value(@cards.first.suit, @trump_suit)
    end
    return @cards.index(max_card)
  end
end
