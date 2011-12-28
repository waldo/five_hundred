class Round
  attr_reader :game, :state, :highest_bid, :tricks, :winning_bidder
  
  def initialize(game)
    deck = Deck.new
    @game = game
    @state = :bidding
    @kitty = deck.deal(3)
    @highest_bid = Bid.empty
    @bidder_order = reset_order
    set_current_bidder(@game.next_dealer)
    @winning_bidder = Player.empty
    @bids = {}; @game.players.each do |p| @bids[p] = [] end
    @tricks = []

    @game.players.each do |p|
      p.assign_cards(deck.deal)
    end
  end

  def bid(new_bid)
    if bid_valid(new_bid)
      @bids[current_bidder] << new_bid
      @highest_bid = new_bid unless new_bid.passed?
      bidding_complete
      next_bidder!
    end
  end

  def discard(discarded_cards)
    if discarded_cards.count == 3
      @winning_bidder.remove_cards(discarded_cards)
      @state = :playing
    end
  end
  
  def play_card(card)
    if @state == :playing and @tricks.last.valid_play?(card, current_player) and (card.joker? ? valid_joker?(card.suit) : true)
      @tricks.last.play(card, current_player)
      next_player!
      trick_complete
    end
  end
  
  def valid_joker?(joker_suit)
    valid =   !played_suits(current_player).include?(joker_suit)
    valid ||= !current_player.suits_excluding_joker(trump_suit).include?(joker_suit) and !voided_suits(current_player).include?(joker_suit)
  end
  
  def played_suits(player)
    played_suits = []
    played_cards(player).each_with_index do |c,i|
      played_suits.push(c.card_suit(@tricks[i].trump_suit))
    end
    played_suits
  end
  
  def played_cards(player)
    played_cards = []
    @tricks.each do |t|
      t.players.each_with_index do |p,i|
        played_cards.push(t.cards[i]) if p == player
      end
    end
    played_cards
  end
  
  def voided_suits(player)
    voided_suits = []
    @tricks.each do |t|
      voided_suits.push(t.cards.first.card_suit(trump_suit)) if guard_voided_suits(t, player)
    end
    voided_suits
  end

  def guard_voided_suits(t, player)
    player_ix = t.players.index(player)
    guard = t.cards.count > 0
    guard &&= !player_ix.nil?
    guard &&= (t.cards.first.card_suit(trump_suit) != t.cards[player_ix].card_suit(trump_suit))
  end
  
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

  def set_current_bidder(p)
    @bidder_order.rotate!(@bidder_order.index(@game.players.index(p)))
  end
  
  def current_player
    if @playing_order.count > 0
      @game.players[@playing_order[0]]
    else
      Player.empty
    end
  end

  def set_current_player(p)
    @playing_order = reset_order
    @playing_order.delete((@game.players.index(@winning_bidder) + 2) % 4) if trump_suit == :misere 
    @playing_order.rotate!(@playing_order.index(@game.players.index(p)))
  end

  def everyone_passed?
    passed_count == 4
  end

  def trump_suit
    @highest_bid.suit
  end

private
  def passed_count
    pass = 0
    @bids.each do |key, bid_list|
      pass += 1 if bid_list.count > 0 and bid_list.last.passed?
    end

    pass
  end

  def reset_order
    [0,1,2,3]
  end

  def bidding_complete
    if ready_for_kitty?
      @state = :kitty
      if @bids[current_bidder].count > 0 and @bids[current_bidder].last.passed?
        @winning_bidder = next_bidder
      else
        @winning_bidder = current_bidder
      end
      @winning_bidder.assign_cards(@kitty)
      @kitty = []
      set_current_player(@winning_bidder)
      @tricks << Trick.new(trump_suit)
    elsif everyone_passed?
      @state = :complete
    end
  end
  
  def bid_valid(new_bid)
    return false if new_bid.nil? or self.state != :bidding
    return true if highest_bid.nil?
    new_bid > highest_bid
  end

  def ready_for_kitty?
    ready = passed_count == 3
    ready &&= !@highest_bid.nil?
    ready ||= @highest_bid.max_bid?
  end

  def trick_complete
    if @playing_order.count == 0
      @tricks.last.winner.team.add_trick_won
      if round_complete?
        @state = :complete
      else
        set_current_player(@tricks.last.winner)
        @tricks << Trick.new(trump_suit)
      end
    end
  end

  def round_complete?
    complete =   @tricks.count == 10 and @playing_order.count == 0
    complete ||= (trump_suit == :misere and @tricks.last.winner == @winning_bidder)
  end

  def next_player(order=@playing_order)
    @game.players[order[1]] unless order.count < 2
  end

  def next_bidder!
    if @bids[current_bidder].count > 0 and @bids[current_bidder].last.passed?
      @bidder_order.delete_at(0)
    else
      @bidder_order.rotate!
    end
  end

  def next_player!
    @playing_order.delete_at(0)
  end
end