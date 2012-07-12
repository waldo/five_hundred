# encoding: UTF-8

module FiveHundred
  module AI
    class Runner
      attr_reader :runs, :players, :results

      def initialize(runs, ais)
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
            @results[p.to_s][@players.index(p)] = { runs: @runs, victories: 0, positive: 0, negative: 0 }
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
          print "#{i}-"
        end

        @results
      end

      def record_results(gw)
        g = gw.instance_variable_get(:@game)
        g.winner.players.each do |p|
          @results[p.to_s][@players.index(p)][:victories] += 1

          if g.positive_team_victory(g.winner)
            @results[p.to_s][@players.index(p)][:positive] += 1
          else
            @results[p.to_s][@players.index(p)][:negative] += 1
          end
        end
      end
      private :record_results
    end
  end
end