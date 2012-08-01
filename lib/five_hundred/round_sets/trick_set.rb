# encoding: UTF-8
require "five_hundred/round_sets/trick"

module FiveHundred
  module RoundSets
    class TrickSet
      attr_reader :trump_suit

      def initialize(trump_suit, players)
        @trump_suit = trump_suit
        @players = players
        @winning_bidder = players.first

        @tricks = [Trick.new(trump_suit)]
        remove_misere_partner
      end

      def remove_misere_partner
        @players.delete_at(2) if @trump_suit == :misere
      end

      def play(card)
        play!(card) if valid_play?(card)
      end

      def play!(card)
        current_trick.play(card, current_player)

        if current_trick.complete? && !complete?
          set_current_player(current_trick.winner)
          next_trick!
        else
          next_player!
        end
      end

      def valid_play?(card)
        valid_play_for_player?(card, current_player)
      end

      def valid_play_for_player?(card, player)
        current_trick.valid_play?(card, player) && joker_rules?(card)
      end
      private :valid_play_for_player?

      def joker_rules?(card)
        !card.joker? || joker_as_regular_trump?(card.suit) || valid_no_trump_joker?(card.suit(@trump_suit))
      end

      def joker_as_regular_trump?(card_suit)
        regular_trumps? && card_suit == :none
      end

      def misere_or_no_trumps?
        [:misere, :none].include?(@trump_suit)
      end

      def regular_trumps?
        !misere_or_no_trumps?
      end

      def valid_no_trump_joker?(joker_suit)
        joker_suit_supplied_if_required?(joker_suit) && (first_play_of_suit?(joker_suit) || (none_remaining_in_suit?(joker_suit) && unvoided_suit?(joker_suit)))
      end

      def joker_suit_supplied_if_required?(joker_suit)
        if misere_or_no_trumps? && current_trick.first_card?
          joker_suit != :none
        else
          true
        end
      end
      private :joker_suit_supplied_if_required?

      def first_play_of_suit?(joker_suit)
        !played_suits(current_player).include?(joker_suit)
      end
      private :first_play_of_suit?

      def none_remaining_in_suit?(joker_suit)
        !current_player.suits_excluding_joker(@trump_suit).include?(joker_suit)
      end
      private :none_remaining_in_suit?

      def unvoided_suit?(joker_suit)
        !voided_suits(current_player).include?(joker_suit)
      end
      private :unvoided_suit?

      def played_suits(player)
        played_cards(player).map {|card| card.suit(@trump_suit) }
      end
      private :played_suits

      def played_cards(player)
        @tricks.map {|t| t.card_played_by(player)}.compact
      end
      private :played_cards

      def all_played_cards
        @tricks.map {|t| t.cards }.flatten
      end
      private :all_played_cards

      def voided_suits(player)
        @tricks.map {|t| t.first_card.suit(@trump_suit) unless t.followed_suit?(player)}.compact
      end

      def valid_cards
        valid_cards_from_set(current_player.cards, current_player)
      end

      def valid_cards_from_set(possible_cards, player)
        joker = Deck.card("Jo")
        possible_cards += joker.joker_suit_variations if [:none, :misere].include?(trump_suit) && possible_cards.include?(joker)

        possible_cards.select {|card| valid_play_for_player?(card, player)}
      end

      def current_trick
        @tricks.last
      end

      def next_trick!
        @tricks << Trick.new(@trump_suit)
      end
      private :next_trick!

      def current_player
        @players.first
      end

      def next_player
        @players.rotate.first
      end

      def next_player!
        @players.rotate!.first
      end
      private :next_player!

      def set_current_player(player)
        while player != current_player
          next_player!
        end
      end

      def tricks_won(team)
        @tricks.reduce(0) do |total, trick|
          total + (trick.winner.team == team ? 1 : 0)
        end
      end

      def tricks_won_by_player(player)
        @tricks.reduce(0) do |total, trick|
          total + (trick.winner == player ? 1 : 0)
        end
      end

      def complete?
        @tricks.count == 10 && current_trick.complete? || (@trump_suit == :misere && current_trick.winner == @winning_bidder)
      end

      def remaining_rank_ordered_cards
        possible_cards = Deck.set_of_cards - all_played_cards
        possible_cards.sort_by {|c| -c.rank(@trump_suit) }
      end

      # class
      def self.empty
        NullObject.new
      end
    end
  end
end
