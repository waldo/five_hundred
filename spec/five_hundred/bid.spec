# encoding: UTF-8
require "spec_helper"

module FiveHundred
  describe "bid" do
    include_context "named bids"

    it "should recognise empty bid" do
      @bid_empty.empty?.should be_true
      @bid_6h.empty?.should be_false
    end

    it "should recognise pass" do
      @pass.passed?.should be_true
      @bid_10nt.passed?.should be_false
    end

    it "should recognise maximum bid" do
      @bid_10nt.max_bid?.should be_true
      @bid_om.max_bid?.should be_false
    end

    it "seven spades should be greater than six hearts" do
      (@bid_7s > @bid_6h).should be_true
    end

    it "closed misere can't be bid if there's no bid" do
      (@bid_cm    > @bid_empty).should  == false
      (@bid_empty > @bid_cm).should     == false
    end

    it "closed misere only allowed between specific bids" do
      (@bid_cm  > @bid_6nt).should be_false
      (@bid_cm  > @bid_7s ).should be_true
      (@bid_cm  > @bid_8s ).should be_false
      (@bid_6nt > @bid_cm ).should be_false
      (@bid_7s  > @bid_cm ).should be_false
      (@bid_8s  > @bid_cm ).should be_true
    end

    it "of any type should be greater than the empty bid" do
      (@bid_6s > @bid_empty).should be_true
      (@bid_empty > @bid_6d).should be_false
    end

    context "bidder" do
      it "should win bid points when they win enough tricks" do
        @bid_7d.bidder_score(7).should    == 180
        @bid_7d.bidder_score(8).should    == 180
      end

      it "should lose bid points when they don't get enough tricks" do
        @bid_10nt.bidder_score(7).should  == -520
        @bid_6h.bidder_score(5).should    == -100
      end

      it "should win 250 points when they win 10 tricks and the bid points are worth less than 250 points" do
        @bid_8s.bidder_score(10).should   == 250
        @bid_6h.bidder_score(10).should   == 250
      end

      it "should win bid points when they win 10 tricks and the bid points are worth more than 250 points" do
        @bid_8c.bidder_score(10).should   == 260
        @bid_8nt.bidder_score(10).should  == 320
      end

      it "should win bid points when they lose all tricks (misére)" do
        @bid_cm.bidder_score(0).should    == 250
        @bid_om.bidder_score(0).should    == 500
      end

      it "should lose bid points when they win any tricks (misére)" do
        @bid_cm.bidder_score(1).should    == -250
        @bid_om.bidder_score(10).should   == -500
      end
    end

    context "non-bidder" do
      it "should win 10 points per trick" do
        @bid_8nt.non_bidder_score(0).should ==   0
        @bid_7nt.non_bidder_score(4).should ==  40
        @bid_9c.non_bidder_score(10).should == 100
      end

      it "shouldn't win any points for misére" do
        @bid_cm.non_bidder_score( 1).should == 0
        @bid_om.non_bidder_score(10).should == 0
      end
    end
  end
end
