# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module AI
    describe "ai" do
      include_context "game support"
      include_context "round support"
      include_context "named bids"

      before(:each) do
        @g = FiveHundred::Game.new
        @ai = OrderedAI.new
        @g.join(@ai)
        add_players(3)
        @r = @g.rounds.last
      end

      context "should respond to requests for" do
        it "bid with a valid bid from the suit it has with most cards" do
          bid = @ai.request(:bid, @g)
          Bid.all.keys.should include(bid.code)
        end

        it "bid and be 10 or less" do
          @ai.clear_cards!
          @ai.assign_cards([Deck.card("Jo"), Deck.card("Jh"), Deck.card("Jd"), Deck.card("Ah"), Deck.card("Kh"), Deck.card("Qh"), Deck.card("10h"), Deck.card("9h"), Deck.card("8h"), Deck.card("7h"), ])

          bid = @ai.request(:bid, @g)
          bid.code == "10h"
        end

        it "kitty with 3 random cards from your hand" do
          win_bid!(@bid_6h, @ai)

          cards = @ai.request(:kitty, @g)
          cards.count.should == 3
          cards.each do |c|
            @ai.cards.should include(c)
          end
        end

        it "play with a card from your hand" do
          win_bid!(@bid_6h, @ai)
          discard_cards!(@ai)

          card = @ai.request(:play, @g)
          @ai.cards.should include(card)
        end

        context "play the joker" do
          it do
            win_bid!(@bid_6h, @ai)
            discard_cards!(@ai)
            @ai.clear_cards!
            @ai.assign_cards([Deck.card("Jo")])

            card = @ai.request(:play, @g)
            card.should == Deck.card("Jo")
            @ai.cards.should include(card)
            @r.play_card(card)
            @ai.cards.count.should == 0
          end

          it "in misére or no trumps round" do
            win_bid!(@bid_8nt, @ai)
            discard_cards!(@ai)
            @ai.clear_cards!
            @ai.assign_cards([Deck.card("Jo")])

            card = @ai.request(:play, @g)
            card.should == Deck.card("Jo")
            @ai.cards.should include(card)
            @r.play_card(card)
            @ai.cards.count.should == 0
          end
        end
      end
    end
  end
end