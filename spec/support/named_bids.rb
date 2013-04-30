# encoding: UTF-8

module FiveHundred
  shared_context "named bids" do
    before do
      @bid_empty  = Bid.empty
      @bid_6s     = Bid.new("6s")
      @bid_6c     = Bid.new("6c")
      @bid_6d     = Bid.new("6d")
      @bid_6h     = Bid.new("6h")
      @bid_6nt    = Bid.new("6nt")
      @bid_7s     = Bid.new("7s")
      @bid_7c     = Bid.new("7c")
      @bid_7d     = Bid.new("7d")
      @bid_7h     = Bid.new("7h")
      @bid_7nt    = Bid.new("7nt")
      @bid_cm     = Bid.new("cm")
      @bid_8s     = Bid.new("8s")
      @bid_8c     = Bid.new("8c")
      @bid_8d     = Bid.new("8d")
      @bid_8h     = Bid.new("8h")
      @bid_8nt    = Bid.new("8nt")
      @bid_9s     = Bid.new("9s")
      @bid_9c     = Bid.new("9c")
      @bid_9d     = Bid.new("9d")
      @bid_9h     = Bid.new("9h")
      @bid_9nt    = Bid.new("9nt")
      @bid_10s    = Bid.new("10s")
      @bid_10c    = Bid.new("10c")
      @bid_10d    = Bid.new("10d")
      @bid_10h    = Bid.new("10h")
      @bid_om     = Bid.new("om")
      @bid_10nt   = Bid.new("10nt")
      @pass       = Bid.pass
    end
  end
end
