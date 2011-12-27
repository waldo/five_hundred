class Team
  attr_reader :players, :tricks_won

  def initialize
    @players = []
    @tricks_won = 0
  end

  def join(new_player)
    if new_player.respond_to?(:each)
      new_player.each do |p|
        add_player(p)
      end
    else
      add_player(new_player)
    end

    self
  end

  def players_required
    @players.count < 2
  end

  def already_joined(p)
    @players.include?(p)
  end
  
  def add_trick_won
    @tricks_won += 1
  end

private
  def add_player(p)
    if players_required and !already_joined(p)
      @players << p
      p.team = self
    end
  end

# class
  def self.empty
    NullObject.new
  end
end