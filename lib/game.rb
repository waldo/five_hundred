class Game
  attr_reader :state, :teams, :rounds

  def initialize
    @state = :setup
    @teams = [Team.new, Team.new]
    @dealer_order = [0,1,2,3].rotate!(rand(4))
    @rounds = []
  end
  
  def join(player, team=Team.empty)
    team = pick_team(team)
    team.join(player) unless already_joined(player)

    start_playing_if_ready

    self
  end

  def already_joined(p)
    players.include?(p)
  end

  def players
    [@teams.first.players.first, @teams.last.players.first, @teams.first.players.last, @teams.last.players.last]
  end
  
  def next_dealer
    players[@dealer_order[1]]
  end
  
  def current_dealer
    players[@dealer_order[0]]
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

  def start_playing_if_ready
    if ready_to_play?
      @rounds << Round.new(self)
      @state = :game_in_progress
    end
  end

  def ready_to_play?
    ready =   !@teams.first.players_required
    ready &&= !@teams.last.players_required
    ready &&= @state == :setup
  end

  def next_dealer!
    @dealer_order.rotate!
  end
  
end