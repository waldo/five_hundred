# encoding: UTF-8

module FiveHundred
  class Round
    attr_reader :game, :state, :highest_bid, :tricks, :winning_bidder

    def initialize(game)
      deck = Deck.new
      @game = game
      @state = :bidding
      @kitty = deck.deal(3)
      @highest_bid = Bid.new("empty")
      @bidder_order = reset_order
      set_current_bidder(@game.next_dealer)
      @winning_bidder = Player.empty
      @bids = {}; @game.players.each do |p| @bids[p] = [] end
      @tricks = []
      @tricks_won = {}; @game.teams.each do |t| @tricks_won[t] = 0 end

      @game.players.each do |p|
        p.assign_cards(deck.deal)
      end
    end

    def reset_order
      [0,1,2,3]
    end
    private :reset_order

    def set_current_bidder(p)
      rotate_to!(@bidder_order, p)
    end
    private :set_current_bidder

    def rotate_to!(order, to_player)
      order.rotate!(order.index(@game.players.index(to_player)))
    end
    private :rotate_to!

    def bid(new_bid)
      if bid_valid(new_bid)
        @bids[current_bidder] << new_bid
        @highest_bid = new_bid unless new_bid.passed?
        bidding_complete
        next_bidder!
      end
    end

    def bid_valid(new_bid)
      return false if new_bid.nil? || self.state != :bidding
      new_bid > @highest_bid
    end
    private :bid_valid

    def bidding_complete
      if ready_for_kitty?
        @state = :kitty
        if @bids[current_bidder].count > 0 && @bids[current_bidder].last.passed?
          @winning_bidder = next_bidder
        else
          @winning_bidder = current_bidder
        end
        @winning_bidder.assign_kitty(@kitty)
        @kitty = []
        set_current_player(@winning_bidder)
        @tricks << Trick.new(trump_suit)
      elsif everyone_passed?
        @state = :complete
      end
    end
    private :bidding_complete

    def ready_for_kitty?
      ready = passed_count == 3
      ready &&= !@highest_bid.empty?
      ready ||= @highest_bid.max_bid?
    end
    private :ready_for_kitty?

    def current_bidder
      if @bidder_order.count > 0
        @game.players[@bidder_order[0]]
      else
        Player.empty
      end
    end

    def next_bidder
      next_player(@bidder_order)
    end

    def next_player(order=@playing_order)
      @game.players[order[1]] unless order.count < 2
    end

    def trump_suit
      @highest_bid.suit
    end

    def set_current_player(p)
      @playing_order = reset_order
      @playing_order.delete((@game.players.index(@winning_bidder) + 2) % 4) if trump_suit == :misere
      rotate_to!(@playing_order, p)
    end
    private :set_current_player

    def everyone_passed?
      passed_count == 4
    end

    def passed_count
      pass = 0
      @bids.each do |key, bid_list|
        pass += 1 if bid_list.count > 0 && bid_list.last.passed?
      end

      pass
    end
    private :passed_count

    def next_bidder!
      if @bids[current_bidder].count > 0 && @bids[current_bidder].last.passed?
        @bidder_order.delete_at(0)
      else
        @bidder_order.rotate!
      end
    end
    private :next_bidder!

    def discard(cards)
      if discard_valid?(cards)
        @winning_bidder.remove_cards(cards)
        @winning_bidder.merge_kitty
        @state = :playing
      end
    end

    def discard_valid?(cards)
      valid = @state == :kitty
      valid &&= cards.count == 3
      valid &&= cards.uniq.count == 3
      cards.each do |c|
        valid &&= @winning_bidder.cards.include?(c)
      end
      valid
    end
    private :discard_valid?

    def play_card(card)
      if valid_play?(card)
        @tricks.last.play(card, current_player)
        next_player!
        trick_complete
      end
    end

    def valid_play?(card)
      @state == :playing && @tricks.last.valid_play?(card, current_player) && joker_rules_ok?(card)
    end

    def current_player
      if @playing_order.count > 0
        @game.players[@playing_order[0]]
      else
        Player.empty
      end
    end

    def joker_rules_ok?(card)
      !card.joker? || valid_joker?(card.suit)
    end

    def valid_joker?(joker_suit)
      valid =   !played_suits(current_player).include?(joker_suit)
      valid ||= !current_player.suits_excluding_joker(trump_suit).include?(joker_suit) && !voided_suits(current_player).include?(joker_suit)
    end
    private :valid_joker?

    def played_suits(player)
      played_suits = []
      played_cards(player).each_with_index do |c,i|
        played_suits.push(c.suit(@tricks[i].trump_suit))
      end
      played_suits
    end
    private :played_suits

    def played_cards(player)
      played_cards = []
      @tricks.each do |t|
        t.players.each_with_index do |p,i|
          played_cards.push(t.cards[i]) if p == player
        end
      end
      played_cards
    end
    private :played_cards

    def voided_suits(player)
      voided_suits = []
      @tricks.each do |t|
        voided_suits.push(t.cards.first.suit(trump_suit)) if guard_voided_suits(t, player)
      end
      voided_suits
    end
    private :voided_suits

    def guard_voided_suits(t, player)
      player_ix = t.players.index(player)
      guard = t.cards.count > 0
      guard &&= !player_ix.nil?
      guard &&= (t.cards.first.suit(trump_suit) != t.cards[player_ix].suit(trump_suit))
    end
    private :guard_voided_suits

    def next_player!
      @playing_order.delete_at(0)
    end
    private :next_player!

    def trick_complete
      if @playing_order.count == 0
        @tricks_won[@tricks.last.winner.team] += 1
        if round_complete?
          round_complete!
        else
          set_current_player(@tricks.last.winner)
          @tricks << Trick.new(trump_suit)
        end
      end
    end
    private :trick_complete

    def round_complete?
      complete =   @tricks.count == 10 and @playing_order.count == 0
      complete ||= (trump_suit == :misere and @tricks.last.winner == @winning_bidder)
    end
    private :round_complete?

    def round_complete!
      @state = :complete
      @game.round_complete
    end
    private :round_complete!

    def score_for(team)
      score = @highest_bid.non_bidder_score(@tricks_won[team])
      score = @highest_bid.bidder_score(@tricks_won[team]) if @winning_bidder.team == team
      score
    end

    def bid_achieved_for?(team)
      @highest_bid.bid_achieved?(@tricks_won[team]) if @winning_bidder.team == team
    end

    def tricks_won_for(team)
      @tricks_won[team]
    end

    def valid_bids
      Bid.all_bids.select {|b| bid_valid(b) }
    end

    def valid_cards
      cards = []
      current_player.cards.each do |c|
        if valid_play?(c)
          cards << c
        elsif [:none, :misere].include?(trump_suit) && c.joker?
          c.joker_suit_variations.each do |j|
            cards << j if valid_play?(j)
          end
        end
      end

      cards
    end
  end
end
