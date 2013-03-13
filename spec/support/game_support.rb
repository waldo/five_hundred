# encoding: UTF-8

module FiveHundred
  shared_context "game support" do
    before do
      def build_game_stub(players=Array.new(4) { double("Player").as_null_object }, teams=Array.new(2) { Team.new })
        @game = double("Game").as_null_object

        @players = players
        @teams = teams

        @game.stub(:teams).and_return(@teams)
        @game.stub(:players).and_return(@players)
        @game.stub(:next_dealer).and_return(@players.first)
        @game.stub(:current_dealer).and_return(@players.last)

        @teams.each_with_index do |t, ix|
          t.join(@players.select.with_index{|p, i| (i + ix) % 2 == 0 })
          @game.stub(:other_team).with(t).and_return(@teams[(ix + 1) % 2])
        end
      end
    end
  end
end
