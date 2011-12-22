class Game
  attr_reader :state, :teams, :dealer

  def initialize
    @state = :setup
    @teams = [Team.new, Team.new]
    @dealer = nil
    @kitty = []
    @deck = Deck.new
  end

  def join(player, team=nil)
    team = pick_team(team)
    team.join(player) unless already_joined(player)

    deal

    self
  end

  def already_joined(p)
    players.include?(p)
  end

  def players
    (@teams.first.players | @teams.last.players)
  end

private
  def team_valid(t)
    @teams.include?(t)
  end

  def pick_team(t)
    team = t
    unless team_valid(t) and t.players_required
      if @teams.first.players_required
        team = @teams.first
      else @teams.last.players_required
        team = @teams.last
      end
    end

    team
  end

  def deal
    if ready_to_deal and @state == :setup
      @state = :bidding
      @dealer = next_dealer
      players.each do |p|
        p.assign_cards(@deck.deal)
      end
      @kitty = @deck.deal(3)
    end
  end

  def ready_to_deal
    !@teams.first.players_required and !@teams.last.players_required
  end

  def next_dealer
    if @dealer.nil?
      return players.sample
    else
      return players[players.index(@dealer) % 4]
    end
  end
end