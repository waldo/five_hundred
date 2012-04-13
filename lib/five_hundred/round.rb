# encoding: UTF-8
require "five_hundred/round_sets/bidding"
require "five_hundred/round_sets/trick_set"

module FiveHundred
  class Round
    attr_reader :game, :state

    def initialize(game)
      @game = game
      @state = :bidding
      @bidding_set = RoundSets::Bidding.new(order_players(@game.next_dealer))
      @trick_set = RoundSets::TrickSet.empty

      deal_cards
    end

    def order_players(player)
      @game.players.rotate(@game.players.index(player)).dup
    end

    def deal_cards
      deck = Deck.new

      @kitty = deck.deal(3)

      @game.players.each do |p|
        p.assign_cards(deck.deal)
      end
    end
    private :deal_cards

    def bid(new_bid)
      if self.state == :bidding
        @bidding_set.bid(new_bid)
        check_after_bid
      end
    end

    def check_after_bid
      if bidding_complete?
        start_kitty_phase!
      elsif everyone_passed?
        @state = :complete
      end
    end
    private :check_after_bid

    def bidding_complete?
      @bidding_set.complete?
    end

    def everyone_passed?
      @bidding_set.everyone_passed?
    end

    def highest_bid
      @bidding_set.highest_bid
    end

    def trump_suit
      highest_bid.suit
    end

    def start_kitty_phase!
      @state = :kitty
      @trick_set = RoundSets::TrickSet.new(trump_suit, order_players(winning_bidder))
      winning_bidder.assign_kitty(@kitty)
      @kitty = []
    end

    def winning_bidder
      @bidding_set.winning_bidder
    end

    def discard_kitty(cards)
      discard!(cards) if discard_valid?(cards)
    end

    def discard_kitty!(cards)
      winning_bidder.remove_cards(cards)
      winning_bidder.merge_kitty
      @state = :playing
    end

    def discard_kitty_valid?(cards)
      state == :kitty && cards.uniq.count == 3 && cards.all? {|c| winning_bidder.cards.include?(c) }
    end

    def play(card)
      if state == :playing
        trick_set.play(card)
        check_after_play
      end
    end

    def trick_set
      @trick_set
    end

    def check_after_play
      round_complete! if tricks_phase_complete?
    end

    def round_complete!
      @state = :complete
      @game.round_complete
    end
    private :round_complete!

    def tricks_phase_complete?
      trick_set.complete?
    end

    def score_for(team)
      score = highest_bid.non_bidder_score(tricks_won_for(team))
      score = highest_bid.bidder_score(tricks_won_for(team)) if winning_bidder.team == team
      score
    end

    def bid_achieved_for?(team)
      highest_bid.bid_achieved?(tricks_won_for(team)) if winning_bidder.team == team
    end

    def tricks_won_for(team)
      trick_set.tricks_won(team)
    end

    def valid_bids
      @bidding_set.valid_bids
    end

    def valid_cards
      trick_set.valid_cards
    end

    def current_bidder
      @bidding_set.current_bidder
    end

    def current_player
      @trick_set.current_player
    end

    def current_trick
      @trick_set.current_trick
    end
  end
end
