# encoding: UTF-8

module FiveHundred
  shared_context "game support" do
    before do
      def add_players(num=4)
        num.times do @g.join(Player.new) end
      end

      @fixed_cards = [
        Deck.cards(%w{4d 4h 5s 5c 5d 5h 6s 6c 6d 6h}),
        Deck.cards(%w{7s 7c 7d 7h 8s 8c 8d 8h 9s 9c}),
        Deck.cards(%w{9d 9h 10s 10c 10d 10h Js Jc Jd Jh}),
        Deck.cards(%w{Qh Ks Kc Kd Kh As Ac Ad Ah Jo}),
      ]
      @kitty_cards = Deck.cards(%w{Qs Qc Qd});

      @game = double("Game").as_null_object
      @players = []; 4.times do @players << double("Player").as_null_object end
      @teams = [Team.new, Team.new]

      @game.stub(:teams) do @teams end
      @game.stub(:players) do @players end
      @game.stub(:next_dealer) do @players.first end
      @game.stub(:current_dealer) do @players.last end


      @fixed_cards.each_with_index do |c,i|
        @players[i].stub(:cards) do c end
        @players[i].stub(:team) do @teams[i%2] end
        @players[i].stub(:team) do @teams[i%2] end
      end
    end
  end
end