class Game
  attr_reader :state, :teams

  def initialize
    @state = :setup
    @teams = [Team.new, Team.new]
  end

  def join(player, team=nil)
    team = pick_team(team)
    team.join(player) unless already_joined(player)

    self
  end

  def already_joined(p)
    @teams.first.already_joined(p) or @teams.last.already_joined(p)
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
end