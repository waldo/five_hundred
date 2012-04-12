# encoding: UTF-8

module FiveHundred
  module AI
    class Runner
      attr_reader :runs, :players, :results

      def initialize(runs, ais)
        @runs = runs
        @results = {}
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
        @results[p.to_s] = { runs: runs, victories: 0, timeouts: 0 }
      end
      private :add_ai

      def run!
        runs.times do
          g = Game.new
          @time = Time.now + 5
          @players.each do |p| g.join(p) end
          while g.state != :complete and timeout
            rnd = g.rounds.last
            while rnd.state == :bidding and timeout
              bid = rnd.current_bidder.request(:bid, g)
              rnd.bid(bid)
            end

            while rnd.state == :kitty and timeout
              cards = rnd.winning_bidder.request(:kitty, g)
              rnd.discard_kitty(cards)
            end

            while rnd.state == :playing and timeout
              card = rnd.current_player.request(:play, g)
              rnd.play_card(card)
            end
          end

          record_results(g)
        end
      end

      def timeout
        @time > Time.now
      end
      private :timeout

      def record_results(g)
        if g.winner == []
          g.players.each do |p|
            @results[p.to_s][:timeouts] += 1
          end
        else
          puts "result: #{g.score_for(g.teams.first)} vs #{g.score_for(g.teams.last)}"
          g.winner.players.each do |p|
            @results[p.to_s][:victories] += 1
          end
        end
      end
      private :record_results
    end
  end
end