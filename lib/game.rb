class Game
  attr_reader :state, :teams, :highest_bid, :tricks

  def initialize
    @state = :setup
    @teams = [Team.new, Team.new]
    @kitty = []
    @highest_bid = Bid.empty
    @dealer_order = reset_order.rotate!(rand(4))
    @bidder_order = @dealer_order.rotate
    @playing_order = reset_order
    @winning_bidder = Player.empty
    @tricks = []
  end
  
  def join(player, team=Team.empty)
    team = pick_team(team)
    team.join(player) unless already_joined(player)

    deal

    self
  end

  def already_joined(p)
    players.include?(p)
  end

  def players
    [@teams.first.players.first, @teams.last.players.first, @teams.first.players.last, @teams.last.players.last]
  end
  
  def bid(new_bid)
    if bid_valid(new_bid)
      current_bidder.assign_bid(new_bid)
      @highest_bid = new_bid unless new_bid.passed?
      next_bidder!
      bidding_complete
    end
  end

  def discard(discarded_cards)
    if discarded_cards.count == 3
      @winning_bidder.remove_cards(discarded_cards)
      @state = :playing
    end
  end
  
  def play_card(card)
    if @state == :playing and current_player.cards.include?(card)
      current_player.remove_cards(card)
      @tricks.first.play(card, current_player)
      next_player!
      trick_complete
    end
  end
  
  def current_dealer
    players[@dealer_order[0]]
  end

  def next_dealer
    next_player(@dealer_order)
  end

  def current_bidder
    if @bidder_order.count > 0
      players[@bidder_order[0]]
    else
      Player.empty
    end
  end

  def next_bidder
    next_player(@bidder_order)
  end

  def set_current_bidder(p)
    @bidder_order.rotate!(@bidder_order.index(players.index(p)))
  end
  
  def current_player
    if @playing_order.count > 0
      players[@playing_order[0]]
    else
      Player.empty
    end
  end

  def set_current_player(p)
    @playing_order.rotate!(@playing_order.index(players.index(p)))
  end

private
  def team_valid?(t)
    @teams.include?(t)
  end

  def pick_team(t)
    team = @teams.last if @teams.last.players_required
    team = @teams.first if @teams.first.players_required
    team = t if team_valid?(t) and t.players_required
    team
  end

  def deal
    if ready_to_deal?
      deck = Deck.new
      @state = :bidding
      next_dealer!
      next_bidder!
      players.each do |p|
        p.assign_cards(deck.deal)
      end
      @kitty = deck.deal(3)
    end
  end

  def ready_to_deal?
    ready =   !@teams.first.players_required
    ready &&= !@teams.last.players_required
    ready &&= @state == :setup
  end

  def redeal
    @state = :setup
    deal
  end

  def bidding_complete
    if ready_for_kitty?
      @state = :kitty
      @winning_bidder = current_bidder
      @winning_bidder.assign_cards(@kitty)
      @kitty = []
      set_current_player(@winning_bidder)
      @tricks << Trick.new(@highest_bid.suit)
    elsif everyone_passed?
      redeal
    end
  end
  
  def bid_valid(new_bid)
    return false if new_bid.nil? or self.state != :bidding
    return true if highest_bid.nil?
    new_bid > highest_bid
  end

  def everyone_passed?
    @bidder_order.count == 0
  end

  def ready_for_kitty?
    ready =   @bidder_order.count == 1
    ready &&= !current_bidder.passed?
    ready &&= !@highest_bid.nil?
    ready ||= @highest_bid.max_bid?
  end

  def trick_complete
    if @playing_order.count == 0
      @tricks.last.winner.team.add_trick_won
      @playing_order = reset_order
      set_current_player(@tricks.last.winner)
    end
  end

  def reset_order
    [0,1,2,3]
  end

  def next_player(order=@playing_order)
    players[order[1]] unless order.count < 2
  end

  def next_dealer!
    @dealer_order.rotate!
  end
  
  def next_bidder!
    if current_bidder.passed?
      @bidder_order.delete_at(0)
    else
      @bidder_order.rotate!
    end
  end

  def next_player!
    @playing_order.delete_at(0)
  end
end