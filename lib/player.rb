class Player
  attr_reader :bids, :cards
  attr_accessor :team

  def initialize
    @cards = []
    @bids = []
    @team = Team.empty
  end

  def assign_cards(cards_to_add)
    @cards += cards_to_add
  end

  def clear_cards!
    @cards = []
  end

  def remove_cards(cards_to_remove)
    if cards_to_remove.respond_to?(:each)
      cards_to_remove.each do |c|
        @cards.delete(c)
      end
    else
      @cards.delete(cards_to_remove)
    end
  end

  def suits_excluding_joker(trump_suit)
    @cards.map do |c|
      c.card_suit(trump_suit) unless c.joker?
    end
  end

# class
  def self.empty
    NullObject.new
  end
end