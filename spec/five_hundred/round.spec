# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "round" do
    include_context "game support"
    include_context "round support"
    include_context "named cards"
    include_context "named bids"

    before(:each) do
      @r = Round.new(@game)
      @pass = Bid.new("pass")
    end

    context "deal" do
      it "" do
        @r.state.should == :bidding
      end

      it "should have first player after dealer as the initial bidder" do
        @r.current_bidder.nil?.should == false
        @r.current_bidder.should == @r.game.players[(@r.game.players.index(@r.game.current_dealer) + 1) % 4]
      end

      it "should distribute cards - 10 to each player" do
        @r.game.players.each do |p|
          p.cards.count.should == 10
        end
      end
    end

    context "bidding" do
      it "should accept inital bid" do
        @r.state.should == :bidding
        bid!(@bid_6h)
        @r.highest_bid.should == @bid_6h
      end

      it "should set a new current bidder once a player has bid" do
        bid!(@bid_6h, @players[0])
        @r.current_bidder.should_not == @players[0]
        @r.current_bidder.should == @players[1]
      end

      it "should have first player as next bidder if last player is current bidder" do
        @r.send(:set_current_bidder, @players[3])
        @r.next_bidder.should == @players[0]
      end

      it "should accept higher bid" do
        bid!([@bid_6h, @bid_7s])
        @r.highest_bid.should == @bid_7s
      end

      it "shouldn't accept lower bid" do
        bid!([@bid_7s, @bid_6h])
        @r.highest_bid.should == @bid_7s
      end

      it "shouldn't accept nil as a bid" do
        bid!([@bid_7s, nil])
        @r.highest_bid.should == @bid_7s
      end

      it "shouldn't accept closed misére unless bid is over 6" do
        bid!([@bid_cm])
        @r.highest_bid.should == @bid_empty

        bid!([@bid_6h, @bid_cm])
        @r.highest_bid.should == @bid_6h

        bid!([@bid_7s, @bid_cm])
        @r.highest_bid.should == @bid_cm
      end

      it "should accept 8S bid over closed misére" do
        bid!([@bid_7s, @bid_cm])
        @r.highest_bid.should == @bid_cm

        bid!(@bid_8s)
        @r.highest_bid.should == @bid_8s
      end

      it "shouldn't accept closed misére if bids are 8 or over" do
        bid!([@bid_8s, @bid_cm])
        @r.highest_bid.should == @bid_8s
      end

      it "should accept pass" do
        bid!(@pass, @players[0])
        @r.highest_bid.empty?.should == true
        bid!([@bid_7s, @pass])
        @r.highest_bid.should == @bid_7s

        bid!(@bid_8s)
        @r.highest_bid.should == @bid_8s
        @r.current_bidder.should == @players[1]
      end

      it "shouldn't accept bid outside of bidding game state" do
        bid!([@pass, @pass, @pass, @pass, @bid_6h])
        @r.highest_bid.empty?.should == true
      end

      it "should end if there is a bid and 3 players pass" do
        bid!([@pass, @pass, @pass])
        @r.state.should == :bidding
        bid!(@bid_6h)
        @r.state.should == :kitty
      end

      it "should end if 10 no trumps is called" do
        bid!([@pass, @pass, @bid_10nt], @players[0])
        @r.winning_bidder.should == @players[2]
        @r.state.should == :kitty
      end

      it "should end if all 4 players pass" do
        bid!([@pass, @pass, @pass, @pass])
        @r.everyone_passed?.should == true
        @r.state.should == :complete
      end

      it "should assign the correct winning bidder" do
        bid!([@pass, @pass, @pass, @bid_6h], @players[0])
        @r.winning_bidder.should == @players[3]
      end
    end

    context "kitty assignment" do
      it "should give 3 cards to winning bidder" do
        @players[0].should_receive(:assign_kitty)

        bid!([@bid_6h, @pass, @pass, @pass], @players[0])
        @r.state.should == :kitty
      end
    end

    context "kitty discard" do
      before(:each) do
        bid!([@bid_6h, @pass, @pass], @players[0])
      end

      it "should not accept discard unless in the kitty phase" do
        @players[0].should_receive(:remove_cards).exactly(0).times

        @r.discard(@players[0].cards.slice(0..2))
        @r.state.should == :bidding
      end

      it "should have winning bidder give back exactly 3 cards" do
        bid!(@pass)
        @players[0].should_receive(:remove_cards)
        @players[0].should_receive(:merge_kitty)

        @r.discard(@players[0].cards.slice(0..2))
        @r.state.should == :playing
      end

      it "should not accept winning bidder providing 1 or 2 cards" do
        bid!(@pass)
        @players[0].should_receive(:remove_cards).exactly(0).times

        @r.discard(@players[0].cards.slice(0..0))
        @r.discard(@players[0].cards.slice(0..1))
        @r.state.should == :kitty
      end

      it "should only discard 3 different cards" do
        bid!(@pass)
        @players[0].should_receive(:remove_cards).exactly(0).times
        @r.discard([@four_diamonds, @four_diamonds, @four_diamonds])
        @r.state.should == :kitty
        @r.discard([@four_diamonds, @five_diamonds, @four_diamonds])
        @r.state.should == :kitty
      end
    end

    context "playing" do
      before(:each) do
        bid!([@pass, @bid_6h, @pass, @pass], @players[0])
      end

      it "shouldn't let player play a card until game is in playing state" do
        @players[1].should_receive(:remove_card).exactly(0).times
        @r.play_card(@eight_spades)
        @r.state.should == :kitty
      end

      it "should let player play a card" do
        discard_cards!
        @players[1].should_receive(:remove_card).with(@players[1].cards.first)
        @r.play_card(@seven_spades)
      end

      it "should not move to the next player if a player plays a card they don't have" do
        discard_cards!
        current_player = @r.current_player
        @r.play_card(@ten_spades)
        @r.current_player.should == current_player
      end

      it "should record trick winner at the end of a trick" do
        discard_cards!
        play_trick!

        @r.tricks.first.winner.should == @players[3]
      end

      it "should have bid winner play the first card of the trick" do
        discard_cards!

        @r.current_player.should == @players[1]
      end

      it "should have trick winner play the first card of all except first trick" do
        discard_cards!
        play_trick!

        @r.current_player.should == @players[3]
      end

      it "should start a new trick after 4 cards are played" do
        discard_cards!
        play_trick!

        @r.tricks.count.should == 2

        play_trick!([@king_diamonds, @five_diamonds, @eight_diamonds, @ten_diamonds,], nil)
        @r.tricks.count.should == 3
      end

      it "should end round after 10 tricks" do
        discard_cards!
        10.times do
          play_trick!([@eight_clubs, @ten_clubs, @ace_clubs, @five_clubs])
        end

        @r.tricks.count.should == 10
        @r.state.should == :complete
      end
    end

    context "playing misere" do
      before(:each) do
        bid!([@bid_7s, @bid_cm, @pass, @pass, @pass], @players[0])
      end

      it "should ensure the misere bidder's partner is skipped" do
        discard_cards!

        @r.current_player.should == @r.game.players[1]
        @r.play_card(@seven_diamonds)
        @r.current_player.should == @r.game.players[2]
        @r.play_card(@nine_diamonds)
        @r.current_player.should == @r.game.players[0]
      end

      it "should start a new trick after 3 cards are played for misere" do
        discard_cards!
        play_trick!([@seven_diamonds, @nine_diamonds, @four_diamonds], nil)

        @r.tricks.count.should == 2
      end

      it "should end round if misere bidder wins a trick" do
        @r = Round.new(@game)
        bid!([@pass, @pass, @pass, @bid_om], @players[0])

        discard_cards!(@players[3])
        play_trick!([@king_diamonds, @four_diamonds, @nine_diamonds], nil)

        @r.tricks.count.should == 1
        @r.state.should == :complete
      end

    end

    context "playing Joker in NT or misere" do
      before(:each) do
        bid!(@bid_10nt, @players[0])
        discard_cards!(@players[0])
      end

      it "as first card in suit" do
        @players[3].stub(:has_suit).and_return(true)
        play_trick!([@four_hearts, @seven_hearts, @nine_hearts], nil)
        @r.play_card(@joker)
        @r.tricks.first.cards.count.should == 3

        @r.play_card(@joker.set_joker_suit(:clubs))
        @r.tricks.first.cards.count.should == 3

        play_trick!([@joker.set_joker_suit(:hearts)], @players[3])
        @r.tricks.first.cards.count.should == 4
      end

      it "as second card in suit not allowed" do
        @players[3].stub(:cards) { Deck.cards(%w{Qh Ks Kd Kh As Ad Ah Jo}) }
        play_trick!([@five_clubs, @seven_clubs, @ten_clubs, @queen_hearts], nil)

        @r.play_card(@nine_hearts)
        @r.tricks.last.cards.count.should == 1
        @r.play_card(@joker.set_joker_suit(:hearts))
        @r.tricks.last.cards.count.should == 1
      end

      it "as last card in suit" do
        @players[3].stub(:cards) do Deck.cards(%w{Qh Ks Kd As Ad Jo}) end
        play_trick!([@five_clubs, @seven_clubs, @ten_clubs, @queen_hearts], nil)
        @players[3].stub(:cards) do Deck.cards(%w{Ks Kd As Ad Jo}) end
        @players[3].stub(:suits_excluding_joker) do [:spades, :diamonds, :spades, :diamonds, nil] end

        @r.play_card(@nine_hearts)
        @r.tricks.last.cards.count.should == 1
        @r.play_card(@joker.set_joker_suit(:hearts))
        @r.tricks.last.cards.count.should == 2
      end

      it "as second last card in suit not allowed" do
        @players[3].stub(:cards) do Deck.cards(%w{Qh Ks Kd Kh As Ad Jo}) end
        play_trick!([@five_clubs, @seven_clubs, @ten_clubs, @queen_hearts], nil)
        @players[3].stub(:cards) do Deck.cards(%w{Ks Kd Kh As Ad Jo}) end
        @players[3].stub(:suits_excluding_joker) do [:spades, :diamonds, :hearts, :spades, :diamonds, nil] end

        @r.play_card(@nine_hearts)
        @r.tricks.last.cards.count.should == 1
        @r.play_card(@joker.set_joker_suit(:hearts))
        @r.tricks.last.cards.count.should == 1
        @r.play_card(@king_hearts)
        @r.tricks.last.cards.count.should == 2
      end

      it "after declaring suit void not allowed" do
        @players[3].stub(:cards) do Deck.cards(%w{Qh Ks Kd As Ad Jo}) end
        play_trick!([@five_clubs, @seven_clubs, @ten_clubs, @queen_hearts], nil)

        @players[3].stub(:cards) do Deck.cards(%w{Ks Kd As Ad Jo}) end
        play_trick!([@nine_hearts, @king_diamonds, @four_hearts, @seven_hearts], nil)

        @players[3].stub(:cards) do Deck.cards(%w{Ks As Ad Jo}) end
        @players[3].stub(:suits_excluding_joker) do [:spades, :spades, :diamonds, nil] end

        @r.play_card(@ten_hearts)
        @r.tricks.last.cards.count.should == 1
        @r.play_card(@joker.set_joker_suit(:hearts))
        @r.tricks.last.cards.count.should == 1
        @r.play_card(@king_spades)
        @r.tricks.last.cards.count.should == 2
      end
    end

    context "should determine" do
      before(:each) do
        bid!([@bid_6nt, @pass, @pass, @pass], @players[0])
        discard_cards!(@players[0])
      end

      it "played cards correctly for a player" do
        play_trick!([@four_hearts, @seven_hearts, @nine_hearts, @queen_hearts], nil)
        play_trick!([@ace_diamonds, @four_diamonds, @seven_diamonds, @nine_diamonds], nil)
        @r.send(:played_cards, @players[0]).count.should == 2
        @r.send(:played_cards, @players[0]).should == [@four_hearts, @four_diamonds]
      end

      it "played suits correctly for a player" do
        play_trick!([@four_hearts, @seven_hearts, @nine_hearts, @queen_hearts], nil)
        play_trick!([@ace_diamonds, @four_diamonds, @seven_diamonds, @nine_diamonds], nil)
        @r.send(:played_suits, @players[0]).should include(:hearts)
        @r.send(:played_suits, @players[0]).should include(:diamonds)
      end

      it "voided suits correctly for a player" do
        @players[3].stub(:cards) do Deck.cards(%w{Qh Ks Kd As Ad Jo}) end
        play_trick!([@five_clubs, @seven_clubs, @ten_clubs, @queen_hearts], nil)
        @r.send(:voided_suits, @players[3]).should include(:clubs)

        @players[3].stub(:cards) do Deck.cards(%w{Ks Kd As Ad Jo}) end
        play_trick!([@nine_hearts, @king_diamonds, @four_hearts, @seven_hearts], nil)
        @r.send(:voided_suits, @players[3]).should include(:hearts)
      end
    end

    context "scoring" do
      it "should determine if the bid is achieved" do
        win_bid!(@bid_6h)
        discard_cards!(@players[0])
        win_x_tricks!(6, 2, 0, 2)

        @r.score_for(@players[0].team).should == 100
        @r.score_for(@players[1].team).should == 40
        @r.bid_achieved_for?(@players[0].team).should == true
        @r.bid_achieved_for?(@players[1].team).should == nil
      end
    end

    context "valid bids" do
      it "should return all bids except closed misere if no bid" do
        @r.valid_bids.should == [
          @bid_6s, @bid_6c, @bid_6d, @bid_6h, @bid_6nt,
          @bid_7s, @bid_7c, @bid_7d, @bid_7h, @bid_7nt,
          @bid_8s, @bid_8c, @bid_8d, @bid_8h, @bid_8nt,
          @bid_9s, @bid_9c, @bid_9d, @bid_9h, @bid_9nt,
          @bid_10s, @bid_10c, @bid_10d, @bid_10h,
          @bid_om,
          @bid_10nt,
          @pass,
        ]
      end

      it "should return all bids after pass bids" do
        @r.bid(@pass)
        @r.bid(@pass)
        @r.valid_bids.should == [
          @bid_6s, @bid_6c, @bid_6d, @bid_6h, @bid_6nt,
          @bid_7s, @bid_7c, @bid_7d, @bid_7h, @bid_7nt,
          @bid_8s, @bid_8c, @bid_8d, @bid_8h, @bid_8nt,
          @bid_9s, @bid_9c, @bid_9d, @bid_9h, @bid_9nt,
          @bid_10s, @bid_10c, @bid_10d, @bid_10h,
          @bid_om,
          @bid_10nt,
          @pass,
        ]
      end

      it "should remove the last bid and bids lower than the last bid" do
        @r.bid(@bid_9d)
        @r.valid_bids.should == [
          @bid_9h, @bid_9nt,
          @bid_10s, @bid_10c, @bid_10d, @bid_10h,
          @bid_om,
          @bid_10nt,
          @pass,
        ]

        @r = Round.new(@game)
        @r.bid(@bid_6nt)
        @r.valid_bids.should == [
          @bid_7s, @bid_7c, @bid_7d, @bid_7h, @bid_7nt,
          @bid_8s, @bid_8c, @bid_8d, @bid_8h, @bid_8nt,
          @bid_9s, @bid_9c, @bid_9d, @bid_9h, @bid_9nt,
          @bid_10s, @bid_10c, @bid_10d, @bid_10h,
          @bid_om,
          @bid_10nt,
          @pass,
        ]
      end


      it "shouldn't contain closed misére unless bid is in the sevens" do
        @r.bid(@bid_6h)
        @r.valid_bids.should_not include(@bid_cm)

        @r.bid(@bid_7s)
        @r.valid_bids.should include(@bid_cm)
      end

      it "shouldn't contain closed misére if bids are 8 or over" do
        @r.bid(@bid_8s)
        @r.valid_bids.should_not include(@bid_cm)
      end

      it "should contain pass" do
        @r.valid_bids.should include(@pass)

        @r.bid(@bid_7s)
        @r.valid_bids.should include(@pass)

        @r.bid(@bid_om)
        @r.valid_bids.should include(@pass)
      end

      it "should have no valid bids after 10nt has been bid" do
        @r.bid(@bid_10nt)
        @r.valid_bids.should == []
      end
    end
  end
end
