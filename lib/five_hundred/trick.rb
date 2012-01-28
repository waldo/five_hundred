# encoding: UTF-8

module FiveHundred
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
      player.remove_card(card)
    end

    def valid_play?(card, player)
      valid = true
      valid &&= card.suit(@trump_suit) == @cards.first.suit(@trump_suit) if @cards.count > 0 and player.has_suit(@cards.first.suit(@trump_suit))
      valid &&= (card.joker? and [:misere, :none].include?(@trump_suit) and @cards.count == 0 ) ? card.suit != :none : true
      valid &&= player.cards.include?(card)
    end

    def winner
      max_card = @cards.max_by do |c|
        c.rank_with_led(@cards.first.suit, @trump_suit)
      end
      return @players[@cards.index(max_card)]
    end

    def led_suit
      cards.first.suit if cards.count > 0
    end
  end
end
