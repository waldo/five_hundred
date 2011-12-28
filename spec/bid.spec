# encoding: UTF-8
require "spec_helper"

describe "bid" do
  include_context "named bids"

  it "should be true if 7s > 6h" do
    (@bid_7s > @bid_6h).should == true
  end
  
  it "should allow you to bid closed misere at the right time" do
    (@bid_cm  > @bid_6nt).should == false
    (@bid_cm  > @bid_7s ).should == true
    (@bid_cm  > @bid_8s ).should == false
    (@bid_6nt > @bid_cm ).should == false
    (@bid_7s  > @bid_cm ).should == false
    (@bid_8s  > @bid_cm ).should == true
  end

  it "of any type should be greater than the empty bid" do
    (@bid_6s > Bid.empty).should == true
    (Bid.empty > @bid_6d).should == false
  end

  context "bidder" do
    it "should win bid points when they win enough tricks" do
      @bid_7d.score_with(7).should    == 180
      @bid_7d.score_with(8).should    == 180
    end

    it "should lose bid points when they don't get enough tricks" do
      @bid_10nt.score_with(7).should  == -520
      @bid_6h.score_with(5).should    == -100
    end

    it "should win 250 points when they win 10 tricks and the bid points worth less than 250 points" do
      @bid_8s.score_with(10).should   == 250
      @bid_6h.score_with(10).should   == 250
    end

    it "should win bid points when they win 10 tricks and the bid points worth more than 250 points" do
      @bid_8c.score_with(10).should   == 260
      @bid_8nt.score_with(10).should  == 320
    end

    it "should win bid points when they lose all tricks (misére)" do
      @bid_cm.score_with(0).should    == 250
      @bid_om.score_with(0).should    == 500
    end

    it "should lose bid points when they win any tricks (misére)" do
      @bid_cm.score_with(1).should    == -250
      @bid_om.score_with(10).should   == -500
    end
  end

  context "non-bidder" do
    it "non-bidder should win 10 points per trick" do
      @bid_8nt.score_with(0, :non_bidder).should ==   0
      @bid_7nt.score_with(4, :non_bidder).should ==  40
      @bid_9c.score_with(10, :non_bidder).should == 100
    end

    it "non-bidder shouldn't win any points for misére" do
      @bid_cm.score_with(1, :non_bidder ).should == 0
      @bid_om.score_with(10, :non_bidder).should == 0
    end
  end
end