class Deck
  attr_reader :cards

  def initialize
    @cards = Deck.set_of_cards.shuffle
  end

  def deal(num=10)
    @cards.slice!(0...num)
  end

  def self.set_of_cards
    cards = []
    card_ranks = %w{5 6 7 8 9 10 J Q K A}
    card_suits = %w{s c d h}
    extra_codes = %w{4d 4h Jo}

    card_ranks.each do |rank|
      card_suits.each do |suit|
        cards << Card.new("#{rank}#{suit}")
      end
    end

    extra_codes.each do |code|
      cards << Card.new(code)
    end

    cards
  end
end