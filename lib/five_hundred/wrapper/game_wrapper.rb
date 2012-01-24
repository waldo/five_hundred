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
        [AI::OrderedAI.new, AI::OrderedAI.new, AI::OrderedAI.new, @player].each do |p| @game.join(p) end
        # run until player request
        @current_round = @game.rounds.last

        self
      end

      def run!
        run until player_request?
      end

      def run
        # check_round_change
        step
        # check_over
      end
      private :run

      def step
        bidding_step if @current_round.state == :bidding
        kitty_step if @current_round.state == :kitty
        play_step if @current_round.state == :playing
      end

      # def check_round_change
      #   unless @current_round == @game.rounds.last
      #     msg(:new_round)
      #     @current_round = @game.rounds.last
      #   end
      #   # if @game.state == :complete
      #   #   msg(:game_over)
      #   # end
      # end

      # def check_over
      # end

      def bidding_step
        current_bidder = @current_round.current_bidder
        if current_bidder == @player
          msg(:request_player_bid)
        else
          bid = current_bidder.request(:bid, @game)
          @current_round.bid(bid)
          msg(:ai_bid, { :position => @game.players.find(current_bidder), :bid => bid.code })
        end
      end

      def kitty_step
        winning_bidder = @current_round.winning_bidder
        if winning_bidder == @player
          msg(:request_player_kitty)
        else
          cards = winning_bidder.request(:kitty, @game)
          @current_round.discard(cards)
          msg(:ai_kitty)
        end
      end

      def play_step
        current_player = @current_round.current_player
        if current_player == @player
          msg(:request_player_play_card)
        else
          card = current_player.request(:play, @game)
          @current_round.play_card(card)
          msg(:ai_play_card, { :position => @game.players.find(current_player), :card => card })
        end
      end

      # def run_step
      #   bidding_step if @current_round.state == :bidding
      #     elsif @current_round.state == :kitty
      #     # elsif @current_round.state == :playing
      #     #   card = @current_round.current_player.request(:play, @game)
      #     #   @current_round.play_card(card)
      #     end
      # end

      def player_request?
        [:request_player_bid, :request_player_kitty, :request_player_play_card, :round_over, :game_over].include? @messages.last.msg if has_messages?
      end
      private :player_request?

      def has_messages?
        @messages.length > 0
      end

      def msg(msg, param={})
        os = OpenStruct.new
        os.msg = msg
        os.player_position = param[:position]
        os.bid = param[:bid]
        os.card = param[:card]
        @messages << os
      end
    end
  end
end
