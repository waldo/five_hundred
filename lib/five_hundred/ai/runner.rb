# encoding: UTF-8

module FiveHundred
  module AI
    class Runner
      attr_reader :runs, :players, :results

      def initialize(runs, *ais)
        @runs = runs
        @results = Hash.new {|h,k| h[k] = {} }
        @players = []
        repeat_add = 1
        repeat_add = 2 if ais.count == 2
        repeat_add = 4 if ais.count == 1

        ais.each do |ai|
          repeat_add.times do
            add_ai(ai)
          end
        end

        self
      end

      def add_ai(ai)
        p = ai.new
        @players << p
      end
      private :add_ai

      def set_results
        @players.each do |p|
          if @results[p.to_s][@players.index(p)].nil?
            @results[p.to_s][@players.index(p)] = { runs: @runs, victories: 0, positive: 0, negative: 0, tricks_won: 0, bid_succeeded: 0, bid_failed: 0, round_count: 0,everyone_passed: 0 }
          else
            @results[p.to_s][@players.index(p)][:runs] += @runs
          end
        end
      end

      def run!
        set_results

        runs.times do |i|
          gw = FiveHundred::Wrapper::GameWrapper.new(@players)

          gw.run!

          record_results(gw)
          print "#{i}..."
        end

        @results
      end

      def record_results(gw)
        game = gw.game

        record_per_player_tricks_won(game)

        record_win(game)
      end
      private :record_results

      def record_per_player_tricks_won(game)
        game.rounds.each do |round|
          @players.each_with_index do |player, i|
            @results[player.to_s][i][:tricks_won] += round.trick_set.tricks_won_by_player(player)
            @results[player.to_s][i][:round_count] += 1
            @results[player.to_s][i][:everyone_passed] += 1 if round.everyone_passed?

            record_bid_accuracy(player, round, i)
          end
        end
      end
      private :record_per_player_tricks_won

      def record_win(game)
        game.winner.players.each do |p|
          win_type = :positive
          p_ix = @players.index(p)

          win_type = :negative unless game.positive_team_victory(game.winner)

          @results[p.to_s][p_ix][:victories] += 1
          @results[p.to_s][p_ix][win_type] += 1
        end
      end
      private :record_win

      def record_bid_accuracy(player, round, results_ix)
        if player == round.winning_bidder
          if round.bid_achieved_for?(player.team)
            @results[player.to_s][results_ix][:bid_succeeded] += 1
          else
            @results[player.to_s][results_ix][:bid_failed] += 1
          end
        end
      end
    end
  end
end
