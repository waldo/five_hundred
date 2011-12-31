# encoding: UTF-8

module FiveHundred
  class Game
    attr_reader :state, :teams, :rounds, :winner

    def initialize
      @state = :setup
      @teams = [Team.new, Team.new]
      @dealer_order = [0,1,2,3].rotate!(rand(4))
      @rounds = []
      @winner = []
    end
  
    def join(player, team=Team.empty)
      team = pick_team(team)
      team.join(player) unless already_joined?(player)

      start_playing_when_ready

      self
    end

    def pick_team(t)
      team = nil
      team = @teams.last if @teams.last.players_required?
      team = @teams.first if @teams.first.players_required?
      team = t if team_valid?(t) and t.players_required?
      team
    end
    private :pick_team

    def team_valid?(t)
      @teams.include?(t)
    end
    private :team_valid?

    def already_joined?(p)
      players.include?(p)
    end
    private :already_joined?

    def players
      [@teams.first.players.first, @teams.last.players.first, @teams.first.players.last, @teams.last.players.last]
    end
  
    def start_playing_when_ready
      play! if ready_to_play?
    end
    private :start_playing_when_ready

    def play!
      players.each do |p|
        p.clear_cards!
      end
      @rounds << Round.new(self)
      @state = :in_progress
    end

    def ready_to_play?
      ready =   !@teams.first.players_required?
      ready &&= !@teams.last.players_required?
      ready &&= @state == :setup
    end
    private :ready_to_play?

    def round_complete
      if game_over?
        game_over!
      else
        play!
      end
    end

    def game_over?
      victorious_teams.count != 0
    end

    def victorious_teams
      victors = []

      @teams.each do |t|
        if score_for(t) >= 500 and bid_achieved?(t)
          victors << t
        elsif score_for(t) <= -500
          victors << other_team(t)
        end
      end

      victors
    end

    def score_for(team)
      @rounds.map{ |r| r.score_for(team) }.reduce(0, :+)
    end

    def bid_achieved?(team)
      @rounds.last.winning_bidder.team == team and @rounds.last.bid_achieved?(team)
    end
    private :bid_achieved?

    def other_team(team)
      @teams.each do |t|
        return t unless t == team
      end
    end

    def game_over!
      @state = :complete
      @winner = victorious_teams.first
    end

    def next_dealer
      players[@dealer_order[1]]
    end
  
    def current_dealer
      players[@dealer_order[0]]
    end

    def next_dealer!
      @dealer_order.rotate!
    end
    private :next_dealer!

    def __test__override_rounds(rounds)
      @rounds = rounds
    end
    private :__test__override_rounds
  end
end