# encoding: UTF-8
require "spec_helper"

describe "bid" do
  it "should be true if 7s > 6h" do
    (Bid.new("7s") > Bid.new("6h")).should == true
  end
  
  it "should allow you to bid closed misere at the right time" do
    (Bid.new("cm")  > Bid.new("6nt")).should == false
    (Bid.new("cm")  > Bid.new("7s" )).should == true
    (Bid.new("cm")  > Bid.new("8s" )).should == false
    (Bid.new("6nt") > Bid.new("cm" )).should == false
    (Bid.new("7s")  > Bid.new("cm" )).should == false
    (Bid.new("8s")  > Bid.new("cm" )).should == true
  end

  it "of any type should be greater than the empty bid" do
    (Bid.new("6s") > Bid.empty).should == true
    (Bid.empty > Bid.new("6d")).should == false
  end
end