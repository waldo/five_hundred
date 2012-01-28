# encoding: UTF-8

module FiveHundred
  class Player
    attr_reader :bids, :cards, :kitty
    attr_accessor :team

    def initialize
      @cards = []
      @kitty = []
      @bids = []
      @team = Team.empty
    end

    def request(type, g)
      @request = type
    end

    def assign_cards(cards_to_add)
      @cards += cards_to_add
    end

    def assign_kitty(cards_to_add)
      @kitty += cards_to_add
    end

    def clear_cards!
      @cards = []
      @kitty = []
    end

    def remove_cards(cards_to_remove)
      cards_to_remove.each do |c|
        remove_card(c)
      end
    end

    def remove_card(to_remove)
      @cards.delete(to_remove)
      @kitty.delete(to_remove)
    end

    def merge_kitty
      @cards += @kitty
      @kitty = []
    end

    def has_suit(suit)
      suits = @cards.map do |c|
        c.suit(suit)
      end

      suits.include?(suit)
    end


    def suits_excluding_joker(trump_suit)
      @cards.map do |c|
        c.suit(trump_suit) unless c.joker?
      end
    end

  # class
    def self.empty
      NullObject.new
    end
  end
end
