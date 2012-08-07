# encoding: UTF-8
require "ostruct"
require "five_hundred/game"
require "five_hundred/player"

module FiveHundred
  module Wrapper
    class GameWrapper
      attr_reader :messages

      def initialize(players=[AI::OrderedAI.new, AI::OrderedAI.new, AI::OrderedAI.new])
        # create game
        @game = Game.new
        # message queue
        @messages = []
        msg(:new_round)
        # add players to game
        @player = Player.new
        players << @player if players.count < 4
        players.each do |p| @game.join(p) end
        # run until player request
        @current_round = @game.current_round

        self
      end

      def run!
        run until player_request?
      end

      def run
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

        @current_trick = @current_round.current_trick
      end
      private :check_trick_change

      def new_trick?
        !@current_trick.nil? && @current_trick != @current_round.current_trick
      end
      private :new_trick?

      def check_round_change
        if new_round?
          msg(:round_over)
          @current_round = @game.current_round
        end
      end
      private :check_round_change

      def new_round?
        @current_round != @game.current_round
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
        bid_step if @current_round.state == :bidding
        kitty_step if @current_round.state == :kitty
        play_step if @current_round.state == :playing
      end
      private :step

      def bid_step
        current_bidder = @current_round.current_bidder
        if current_bidder == @player
          msg(:request_player_bid)
        else
          bid = current_bidder.request(:bid)
          @current_round.bid(bid)
          msg(:ai_bid, { :position => @game.players.find(current_bidder), :bid => bid.code })
        end
      end
      private :bid_step

      def kitty_step
        winning_bidder = @current_round.winning_bidder
        if winning_bidder == @player
          msg(:request_player_kitty_discard)
        else
          cards = winning_bidder.request(:kitty)
          @current_round.discard_kitty(cards)
          msg(:ai_kitty_discard)
        end
      end
      private :kitty_step

      def play_step
        current_player = @current_round.current_player
        if current_player == @player
          msg(:request_player_play_card)
        else
          card = current_player.request(:play)
          @current_round.play_card(card)
          msg(:ai_play_card, { :position => @game.players.find(current_player), :card => card })
        end
      end
      private :play_step

      def player_request?
        [:request_player_bid, :request_player_kitty_discard, :request_player_play_card, :round_over, :game_over].include? @messages.last.msg if has_messages?
      end
      private :player_request?

      def player_bid(bid_code)
        @current_round.bid(Bid.new(bid_code))
      end

      def player_discard_kitty(card_codes)
        cards = card_codes.map {|code| Deck.card(code) }
        @current_round.discard_kitty(cards)
      end

      def player_play_card(card_code)
        @current_round.play_card(Deck.card(card_code))
      end

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

      def game_score_at_team_position(team_position)
        team = @game.teams[team_position]
        @game.score_for(team)
      end

      def round_score_at_team_position(team_position)
        team = @game.teams[team_position]
        @current_round.score_for(team)
      end

      def get_card_codes
        cards = @player.cards
        cards.map {|c| c.code }
      end

      def get_kitty_card_codes
        cards = @player.kitty_cards
        cards.map {|c| c.code }
      end

      def valid_bids
        bids = @current_round.valid_bids
        bids.map {|b| b.code }
      end

      def valid_cards
        cards = @current_round.valid_cards
        cards.map {|c| c.code }
      end

      def bid_at_team_position(team_position)
        team = @game.teams[team_position]
        return "" unless @current_round.winning_bidder.team == team
        @current_round.highest_bid.code
      end

      def tricks_won_at_team_position(team_position)
        team = @game.teams[team_position]
        @current_round.tricks_won_for(team)
      end

      def game_winner_at_player_position(player_position)
        team = @game.players[player_position].team
        @game.winner == team
      end
    end
  end
end
