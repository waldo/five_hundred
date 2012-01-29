# encoding: UTF-8

module FiveHundred
  class Deck
    attr_reader :cards

    def initialize
      @cards = Deck.set_of_cards.shuffle
    end

    def deal(num=10)
      @cards.slice!(0...num)
    end

  # class
    class << self; attr_accessor :card_definitions, :joker_special_definitions end

    @card_definitions = {
      "4d" => { rank: 4, suit: :diamonds },
      "4h" => { rank: 4, suit: :hearts },
      "5s" => { rank: 5, suit: :spades },
      "5c" => { rank: 5, suit: :clubs },
      "5d" => { rank: 5, suit: :diamonds },
      "5h" => { rank: 5, suit: :hearts },
      "6s" => { rank: 6, suit: :spades },
      "6c" => { rank: 6, suit: :clubs },
      "6d" => { rank: 6, suit: :diamonds },
      "6h" => { rank: 6, suit: :hearts },
      "7s" => { rank: 7, suit: :spades },
      "7c" => { rank: 7, suit: :clubs },
      "7d" => { rank: 7, suit: :diamonds },
      "7h" => { rank: 7, suit: :hearts },
      "8s" => { rank: 8, suit: :spades },
      "8c" => { rank: 8, suit: :clubs },
      "8d" => { rank: 8, suit: :diamonds },
      "8h" => { rank: 8, suit: :hearts },
      "9s" => { rank: 9, suit: :spades },
      "9c" => { rank: 9, suit: :clubs },
      "9d" => { rank: 9, suit: :diamonds },
      "9h" => { rank: 9, suit: :hearts },
      "10s" => { rank: 10, suit: :spades },
      "10c" => { rank: 10, suit: :clubs },
      "10d" => { rank: 10, suit: :diamonds },
      "10h" => { rank: 10, suit: :hearts },
      "Js" => { rank: 11, suit: :spades },
      "Jc" => { rank: 11, suit: :clubs },
      "Jd" => { rank: 11, suit: :diamonds },
      "Jh" => { rank: 11, suit: :hearts },
      "Qs" => { rank: 12, suit: :spades },
      "Qc" => { rank: 12, suit: :clubs },
      "Qd" => { rank: 12, suit: :diamonds },
      "Qh" => { rank: 12, suit: :hearts },
      "Ks" => { rank: 13, suit: :spades },
      "Kc" => { rank: 13, suit: :clubs },
      "Kd" => { rank: 13, suit: :diamonds },
      "Kh" => { rank: 13, suit: :hearts },
      "As" => { rank: 14, suit: :spades },
      "Ac" => { rank: 14, suit: :clubs },
      "Ad" => { rank: 14, suit: :diamonds },
      "Ah" => { rank: 14, suit: :hearts },
      "Jo" => { rank: 100, suit: :none },
    }

    def self.set_of_cards
      cards = []

      Deck.card_definitions.each do |key, val|
        cards << Card.new(key, val[:rank], val[:suit])
      end

      cards
    end

    def self.card(code)
      Card.new(code, Deck.card_definitions[code][:rank], Deck.card_definitions[code][:suit])
    end

    def self.cards(codes)
      cards = []
      codes.each do |c|
        cards << Deck.card(c)
      end

      cards
    end
  end
end
