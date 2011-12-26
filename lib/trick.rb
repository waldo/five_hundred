class Trick
  def initialize(trump_suit)
    @trump_suit = trump_suit
    @cards = []
    @players = []
  end

  def play(card, player)
    @cards.push(card)
    @players.push(player)
  end
  
  def winner
    max_card = @cards.max_by do |c|
      c.card_value(@cards.first.suit, @trump_suit)
    end
    return @players[@cards.index(max_card)]
  end
end
