# encoding: UTF-8
require "spec_helper"

describe "game" do
  def add_players(num=4)
    num.times do @g.join(Player.new) end
  end

  before(:each) do
    @g = Game.new
    @p = Player.new
    @t1 = @g.teams.first
    @t2 = @g.teams.last
  end

  context "creation" do
    it "" do
      @g.state.should == :setup
      @g.teams.count.should == 2
    end
  end

  context "join" do
    it "shouldn't allow the same player twice" do
      @g.join(@p, @t1).join(@p, @t2)

      @t1.players.count.should == 1
      @t2.players.count.should == 0
    end

    it "should assign players with teams" do
      @g.join(Player.new, @t1).join(Player.new, @t1)
      @g.join(Player.new, @t2).join(Player.new, @t2)

      @t1.players.count.should == 2
      @t2.players.count.should == 2
    end

    it "should assign players without selecting teams" do
      add_players
      @t1.players.count.should == 2
      @t2.players.count.should == 2
    end
    
    it "should set player order so positions 0 and 1 are not held by the same team" do
      add_players
      [@t1, @t2].each do |t|
        (@g.players.index(t.players.first) - @g.players.index(t.players.last)).abs.should == 2
      end
    end
    
  end

  context "deal" do
    it "" do
      add_players
      @g.state.should == :bidding
    end

    it "should assign a player as the 'dealer'" do
      add_players
      @g.players.should include(@g.current_dealer)
      @g.current_dealer.nil?.should == false
    end

    it "should distribute cards - 10 to each player" do
      add_players

      @g.players.each do |p|
        p.cards.count.should == 10
      end
    end

    it "shouldn't happen if there are 3 players" do
      add_players(3)
      @g.state.should_not == :bidding
    end
  end

  context "bidding" do
    before(:each) do
      add_players
      @six_hearts = Bid.new("6h")
      @seven_spades = Bid.new("7s")
      @eight_spades = Bid.new("8s")
      @closed_misere = Bid.new("cm")
      @ten_no_trumps = Bid.new("10nt")
      @pass = Bid.new("pass")
    end
  
    it "should have first player after dealer as the initial bidder" do
      @g.current_bidder.nil?.should == false
      @g.current_bidder.should == @g.players[(@g.players.index(@g.current_dealer) + 1) % 4]
    end
    
    it "should accept inital bid" do
      @g.state.should == :bidding
      @g.bid(@six_hearts)
      @g.highest_bid.should == @six_hearts
    end

    it "should set a new current bidder once a player has bid" do
      old_bidder = @g.current_bidder
      @g.bid(@six_hearts)
      @g.current_bidder.should_not == old_bidder
      @g.current_bidder.should == @g.players[(@g.players.index(old_bidder) + 1) % 4]
    end

    it "should have first player as next bidder if last player is current bidder" do
      @g.set_current_bidder(@g.players.last)
      @g.next_bidder.nil?.should == false
      @g.next_bidder.should == @g.players[(@g.players.index(@g.current_bidder) + 1) % 4]
    end

    it "should accept higher bid" do
      @g.bid(@six_hearts)
      @g.bid(@seven_spades)
      @g.highest_bid.should == @seven_spades
    end

    it "shouldn't accept lower bid" do
      @g.bid(@seven_spades)
      @g.bid(@six_hearts)
      @g.highest_bid.should == @seven_spades
    end
    
    it "shouldn't accept nil as a bid" do
      @g.bid(@seven_spades)
      @g.bid(nil)
      @g.highest_bid.should == @seven_spades
    end

    it "shouldn't accept closed misére unless bid is over 6" do
      @g.bid(@six_hearts)
      @g.bid(@closed_misere)
      @g.highest_bid.should == @six_hearts
      @g.bid(@seven_spades)
      @g.bid(@closed_misere)
      @g.highest_bid.should == @closed_misere
    end
    
    it "should accept 8S bid over closed misére" do
      @g.bid(@seven_spades)
      @g.bid(@closed_misere)
      @g.highest_bid.should == @closed_misere
      @g.bid(@eight_spades)
      @g.highest_bid.should == @eight_spades
    end
    
    it "shouldn't accept closed misére if bids are 8 or over" do
      @g.bid(@eight_spades)
      @g.bid(@closed_misere)
      @g.highest_bid.should == @eight_spades
    end

    it "should accept pass" do
      @g.bid(@pass)
      @g.highest_bid.nil?.should == true
      second_bidder = @g.current_bidder

      @g.bid(@seven_spades)
      @g.bid(@pass)
      @g.highest_bid.should == @seven_spades

      @g.bid(@eight_spades)
      @g.highest_bid.should == @eight_spades
      @g.current_bidder.should == second_bidder
    end

    it "shouldn't accept bid outside of bidding game state" do
      g = Game.new
      g.bid(@six_hearts)
      g.highest_bid.nil?.should == true
    end

    it "should end if there is a bid and 3 players pass" do
      @g.bid(@pass)
      @g.bid(@pass)
      @g.bid(@pass)
      @g.state.should == :bidding
      @g.bid(@six_hearts)
      @g.state.should == :kitty
    end

    it "should end if 10 no trumps is called" do
      @g.bid(@pass)
      @g.bid(@pass)
      @g.bid(@ten_no_trumps)
      @g.state.should == :kitty
    end

    it "should end if all 4 players pass" do
      hand = @g.players.first.cards
      @g.bid(@pass)
      @g.bid(@pass)
      @g.bid(@pass)
      @g.bid(@pass)
      @g.state.should == :bidding
      @g.players.first.cards.should_not == hand
      # todo: check round is different instead of relying on hand randomly being different
    end
  end
end