class Game
  attr_reader :state, :players

  def initialize
    @state = :setup
    @players = []
  end

  def join(new_player)
    @players << new_player if players_required and !already_playing(new_player)
    self
  end

  def players_required
    return @players.count < 4
  end

  def already_playing(p)
    return @players.include?(p)
  end
end