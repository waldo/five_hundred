# encoding: UTF-8
require "five_hundred/team"

module FiveHundred
  class Player
    attr_reader :kitty, :discarded_kitty
    attr_accessor :team, :game

    def initialize
      @cards = []
      @kitty = []
      @discarded_kitty = []
      @team = Team.empty
      @game = nil
    end

    def round
      game.current_round
    end

    def request(type)
      self.send("request_#{type}")
    end

    def assign_cards(cards_to_add)
      clear_cards!
      @cards += cards_to_add
    end

    def assign_kitty(cards_to_add)
      @kitty += cards_to_add
    end

    def cards
      @cards + Array(@kitty)
    end

    def clear_cards!
      @cards = []
      @kitty = []
    end
    private :clear_cards!

    def discard_kitty(cards)
      @discarded_kitty = cards
      remove_cards(cards)
      merge_kitty
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

    def has_card(card)
      @cards.include?(card)
    end

    def suits(trump_suit)
      @cards.map {|c| c.suit(trump_suit)}
    end

    def suits_excluding_joker(trump_suit)
      @cards.map {|c| c.suit(trump_suit) unless c.joker?}.compact
    end

    def partner
      return nil if team.nil?

      team.players - Array(self)
    end

    def opponents
      @game.other_team(team).players
    end

    # class
    def self.empty
      NullObject.new
    end
  end
end
