# encoding: UTF-8
require "spec_helper"

describe "round" do
  include_context "mocked game"
  include_context "named cards"
  include_context "named bids"

  before(:each) do
    @r = Round.new(@game)
    @pass = Bid.new("pass")
  end
  
  def discard_cards!(for_player=@players[1])
    @r.discard(for_player.cards.slice(0..2))
  end
  
  def play_trick!(cards=[@eight_spades,@ten_spades,@ace_spades,@five_spades], set_current=1)
    @r.send(:set_current_player, @players[set_current]) unless set_current.nil?
    cards.each do |c|
      @r.play_card(c)
    end
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
      @r.highest_bid.nil?.should == true
      bid!([@bid_7s, @pass])
      @r.highest_bid.should == @bid_7s

      bid!(@bid_8s)
      @r.highest_bid.should == @bid_8s
      @r.current_bidder.should == @players[1]
    end

    it "shouldn't accept bid outside of bidding game state" do
      bid!([@pass, @pass, @pass, @pass, @bid_6h])
      @r.highest_bid.nil?.should == true
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
      @players[0].should_receive(:assign_cards)
      bid!([@bid_6h, @pass, @pass, @pass], @players[0])
      @r.state.should == :kitty
    end
  end

  context "kitty discard" do
    before(:each) do
      bid!([@bid_6h, @pass, @pass, @pass], @players[0])
    end

    it "should have winning bidder give back exactly 3 cards" do
      @players[0].should_receive(:remove_cards)
      @r.discard(@players[0].cards.slice(0..2))
      @r.state.should == :playing
    end

    it "should only discard cards in the winning bidder's hand" do
      @players[0].should_receive(:remove_cards).exactly(0).times
      @r.discard([@ace_spades, @ace_clubs, @ace_diamonds])
      @r.state.should == :kitty
    end

    it "should only discard 3 different cards" do
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
      @players[1].should_receive(:remove_cards).exactly(0).times
      @r.play_card(@eight_spades)
      @r.state.should == :kitty
    end

    it "should let player play a card" do
      discard_cards!
      @players[1].should_receive(:remove_cards).with(@players[1].cards.first)
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
    
    it "should count how many tricks are won by each team" do
      discard_cards!
      play_trick!

      @players[3].team.tricks_won.should == 1
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
      play_trick!([@four_hearts, @seven_hearts, @nine_hearts], nil)
      @r.play_card(@joker)
      @r.tricks.first.cards.count.should == 3

      @r.play_card(@joker.set_joker_suit(:clubs))
      @r.tricks.first.cards.count.should == 3

      play_trick!([@joker.set_joker_suit(:hearts)], 3)
      @r.tricks.first.cards.count.should == 4
    end

    it "as second card in suit not allowed" do
      @players[3].stub(:cards) do Deck.cards(%w{Qh Ks Kd Kh As Ad Ah Jo}) end
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
end