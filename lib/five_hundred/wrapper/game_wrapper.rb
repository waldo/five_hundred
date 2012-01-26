# encoding: UTF-8
require "ostruct"
require "pry-nav"

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
        binding.pry
        check_trick_change
        check_round_change
        check_game_over
        step
      end
      private :run

      def check_trick_change
        if new_trick?
          msg(:trick_over, { :position => @game.players.find(@current_trick.winner) })
        end

        @current_trick = @current_round.tricks.last
      end
      private :check_trick_change

      def new_trick?
        @current_trick != @current_round.tricks.last && !@current_trick.nil?
      end
      private :new_trick?

      def check_round_change
        if new_round?
          msg(:round_over)
          @current_round = @game.rounds.last
        end
      end
      private :check_round_change

      def new_round?
        @current_round != @game.rounds.last
      end
      private :new_round?

      def check_game_over
        if game_over?
          msg(:game_over)
        end
      end
      private :check_game_over

      def game_over?
        @game.state == :complete
      end
      private :game_over?

      def step
        bidding_step if @current_round.state == :bidding
        kitty_step if @current_round.state == :kitty
        play_step if @current_round.state == :playing
      end
      private :step

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
      private :bidding_step

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
      private :kitty_step

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
      private :play_step

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
