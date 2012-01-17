# encoding: UTF-8
require "ostruct"

module FiveHundred
  module Wrapper
    class GameWrapper
      attr_reader :messages

      def initialize
        # create game
        @game = Game.new
        # message queue
        @messages = []
        msg(:new_round)
        # add players to game
        @player = Player.new
        [AI::RandomAI.new, AI::RandomAI.new, AI::RandomAI.new, @player].each do |p| @game.join(p) end
        # run until player request
        @current_round = @game.rounds.last

        self
      end

      def run!
        run
      end

      def run
        unless @current_round == @game.rounds.last
          msg(:new_round)
          @current_round = @game.rounds.last
        end

        while !player_request?
          debugger
          if @current_round.state == :bidding
            if @current_round.current_bidder == @player
              msg(:request_player_bid)
            else
              bid = @current_round.current_bidder.request(:bid, @game)
              msg(:ai_bid, @game.players.find(@current_round.current_bidder), bid.code)
              @current_round.bid(bid)
            end
          elsif @current_round.state == :kitty
            if @current_round.current_player == @player
              msg(:request_player_kitty)
            else
              cards = @current_round.winning_bidder.request(:kitty, @game)
              msg(:ai_kitty)
              @current_round.discard(cards)
            end
          # elsif @current_round.state == :playing
          #   card = @current_round.current_player.request(:play, @game)
          #   @current_round.play_card(card)
          end
        end
      end
      private :run

      def player_request?
        [:request_player_bid, :request_player_kitty, :request_player_play_card, :round_over, :game_over].include? @messages.last.msg if has_messages?
      end
      private :player_request?

      def has_messages?
        @messages.length > 0
      end

      def msg(msg, position=nil, bid=nil)
        os = OpenStruct.new
        os.msg = msg
        os.player_position = position
        os.bid = bid
        @messages << os
      end
    end
  end
end
