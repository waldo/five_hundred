class Trick
  attr_reader :cards, :players, :trump_suit

  def initialize(trump_suit)
    @cards = []
    @players = []
    @trump_suit = trump_suit
  end

  def play(card, player)
    @cards.push(card)
    @players.push(player)
    player.remove_cards(card)
  end
  
  def valid_play?(card, player)
    valid = true
    valid &&= card.card_suit(@trump_suit) == @cards.first.card_suit(@trump_suit) if @cards.count > 0 and suits_in_hand(player)
    valid &&= (card.joker? and [:misere, :none].include?(@trump_suit) and @cards.count == 0 ) ? card.suit != :none : true
    valid &&= player.cards.include?(card)
  end

  def suits_in_hand(player)
    suits = player.cards.map do |c|
      c.card_suit(@trump_suit)
    end
    suits.include?(@cards.first.card_suit(@trump_suit))
  end
  
  def winner
    max_card = @cards.max_by do |c|
      c.card_value(@cards.first.suit, @trump_suit)
    end
    return @players[@cards.index(max_card)]
  end
end
