class Game
  attr_reader :state

  def initialize
    @state = :setup
  end
end