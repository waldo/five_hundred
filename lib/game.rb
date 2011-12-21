class Game
  attr_reader :state, :teams

  def initialize
    @state = :setup
    @teams = [Team.new, Team.new]
  end

  def join(player, team)
    team.join(player) if team_valid(team) and !already_joined(team)

    self
  end
  
  def team_valid(t)
    @teams.include?(t)
  end

  def already_joined(t)
    @teams.first.already_joined(t) or @teams.last.already_joined(t)
  end
end