# encoding: UTF-8

module FiveHundred
  module RoundSets
    class Trick
      attr_reader :card_set, :players, :trump_suit

      def initialize(trump_suit)
        @card_set = {}
        @trump_suit = trump_suit
      end

      def play(card, player)
        @card_set[player] = card
        player.remove_card(card)
      end

      def valid_play?(card, player)
        valid = player.has_card(card)
        valid &&= card.suit(@trump_suit) == led_suit if !first_card? && has_led_suit?(player)
        valid
      end

      def winner
        player, max_card = @card_set.max_by {|player, card| rank(card)} if complete?

        player.nil? ? Player.empty : player
      end

      def rank(card)
        card.rank_with_led(first_card.suit, @trump_suit)
      end
      private :rank

      def led_suit
        first_card.suit(@trump_suit) unless first_card?
      end

      def complete?
        @card_set.count == 4 || (@card_set.count == 3 && @trump_suit == :misere)
      end

      def has_led_suit?(player)
        player.suits(@trump_suit).include?(led_suit)
      end

      def first_card
        @card_set.first[1]
      end

      def first_card?
        @card_set.count == 0
      end

      def card_played_by(player)
        @card_set[player]
      end

      def followed_suit?(player)
        @card_set[player].nil? || first_card.suit(@trump_suit) == @card_set[player].suit(@trump_suit)
      end
    end
  end
end