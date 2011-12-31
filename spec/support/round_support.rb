# encoding: UTF-8

module FiveHundred
  shared_context "round support" do
    def discard_cards!(for_player=@players[1])
      @r.discard(for_player.cards.slice(0..2))
    end

    def win_x_tricks!(tricks0, tricks1, tricks2, tricks3)
      num_to_win = [tricks0, tricks1, tricks2, tricks3]
      num_to_win.each_with_index do |num, i|
        @players.each do |p|
          p.stub(:cards) { Deck.cards(%w{4d}) }
        end
        @players[i].stub(:cards) { Deck.cards(%w{Jo}) }

        num.times do
          play_trick!([@joker, @four_diamonds, @four_diamonds, @four_diamonds], @players[i])
        end
      end
    end

    def play_trick!(cards=[@eight_spades,@ten_spades,@ace_spades,@five_spades], player_going_first=@players[1])
      @r.send(:set_current_player, player_going_first) unless player_going_first.nil?
      cards.each do |c|
        @r.play_card(c)
      end
    end

    def win_bid!(bid, bidder_to_win=@players[0])
      bid!([bid, @pass, @pass, @pass], bidder_to_win)
    end

    def bid!(bids, first_bidder=nil)
      @r.send(:set_current_bidder, first_bidder) unless first_bidder.nil?
      if bids.respond_to?(:each)
        bids.each do |b|
          @r.bid(b)
        end
      else
        @r.bid(bids)
      end
    end
  end
end