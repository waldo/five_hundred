# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class RuleAI < GeneralAI
# request bid
      def request_bid
        max_bid = bid
        return max_bid if max_bid.passed?

        stepped_bid(max_bid)
      end

      def stepped_bid(max_bid)
        max_req = max_bid.tricks_required
        min_req = [6, max_req - 1].max
        range = min_req..max_req
        range.each do |tricks_req|
          my_bid = Bid.create_with_tricks_and_suit(tricks_req, max_bid.suit)
          return my_bid if my_bid > round.highest_bid
        end

        Bid.pass
      end
      private :stepped_bid

      def bid
        suit_to_bid, score = score_per_suit.first
        # +0.9 if partner bids the suit
        score += 0.9 if round.bid_for_player(self.partner).suit == suit_to_bid
        tricks_req = [score.round, 10].min

        puts "#{suit_to_bid} (#{score} => #{tricks_req}): #{cards.map(&:code)}"

        if tricks_req < 6
          return Bid.pass
        end

        Bid.create_with_tricks_and_suit(tricks_req, suit_to_bid)
      end
      private :bid

      def score_per_suit
        suits_scores_arr = cards_by_suit.map do |suit, cards_in_suit|
          [suit, score_cards(suit, cards_in_suit)]
        end

        suits_scores_arr.sort_by {|suit, score| -score }
      end
      private :score_per_suit

      def score_cards(suit, cards_in_suit)
        sum_scores = 0.0

        self.cards.map do |c|
          sum_scores += rank_to_score(c.rank[suit][nil])
        end

        sum_scores
      end
      private :score_cards

      def rank_to_score(rank)
        score = -0.2

        if rank == 31
          score = 2.35
        elsif rank >= 29
          score = 1.75
        elsif rank >= 26
          score = 1.35
        elsif rank >= 14
          score = 0.95
        elsif rank >= 12
          score = 0.10
        end

        score
      end
      private :rank_to_score

# request play
      def request_play
        return misere_play if round.highest_bid.misere?

        trumps_play
      end

      def misere_play
        lowest_card
      end

      def trumps_play
        return highest_card if one_valid_choice?
        return position_rules if winnable_trick?

        return lowest_card
      end

      def position_rules
        position_symbols = {0 => :first, 1 => :second, 2 => :third, 3 => :fourth}
        position = trick.cards.count

        send("playing_trumps_#{position_symbols[position]}")
      end
      private :position_rules

      def playing_trumps_first
        return highest_card if guaranteed_winner?

        return lowest_trump if reverse_bleed?

        return expected_non_trump_winner || lowest_card
      end
      private :playing_trumps_first

      def playing_trumps_second
        return highest_card if trump_suit_led?
        return lowest_trump if can_use_trump? && opponents_short_trumps_or_have_suit?(trick.led_suit)

        return highest_card
      end
      private :playing_trumps_second

      def playing_trumps_third
        return lowest_card if partner_played_guaranteed_winner? || top_card_equivalent_to_partners_card?

        return playing_trumps_second
      end
      private :playing_trumps_third

      def playing_trumps_fourth
        return lowest_card if partner_winning?

        return lowest_winner
      end
      private :playing_trumps_fourth

      def reverse_bleed?
        has_trumps?(round.trump_suit) && round.winning_bidder.team == self.team && round.tricks_count <= 3
      end
      private :reverse_bleed?

      def expected_non_trump_winner
        top_cards_non_trump_suit.each do |card|
          return card if opponents_short_trumps_or_have_suit?(card.suit[round.trump_suit])
        end

        nil
      end

      def opponents_short_trumps_or_have_suit?(suit)
        remaining_opponents.all? do |opponent|
          guess_player_has_suit?(opponent, suit) || !guess_player_has_suit?(opponent, round.trump_suit)
        end
      end

      def one_valid_choice?
        round.valid_cards.count == 1
      end

      def guaranteed_winner?
        top_card = round.remaining_cards_plus_current_trick.first

        top_card == round.valid_cards.first
      end

      def partner_played_guaranteed_winner?
        ranked_cards = round.remaining_cards_plus_current_trick - cards
        ranked_cards = ranked_cards - round.remaining_cards(round.trump_suit) if round.voided_suits(remaining_opponents.first).include?(round.trump_suit)
        top_card = ranked_cards.first
        partner_played = trick.card_played_by(self.partner)

        top_card == partner_played
      end

      def top_card_equivalent_to_partners_card?
        partner_played = trick.card_played_by(self.partner)
        my_cards_except_top = round.valid_cards.drop(1)
        remaining = round.remaining_cards_plus_current_trick - my_cards_except_top

        remaining.index(partner_played) - remaining.index(highest_card) == 1
      end

      def top_cards_non_trump_suit
        suits = [:spades, :clubs, :diamonds, :hearts]
        suits.delete(round.trump_suit)

        top_cards = suits.map {|s| round.remaining_cards(s).first }

        top_cards.select {|card| round.valid_cards.include?(card) }
      end

      def guess_player_has_suit?(player, suit)
        !round.voided_suits(player).include?(suit) && (round.remaining_cards(suit) - cards).count >= 3
      end

      def trump_suit_led?
        round.trump_suit == trick.led_suit
      end

      def winnable_trick?
        highest_card.rank[round.trump_suit][trick.led_suit] > trick.max_rank
      end

      def can_use_trump?
        highest_card.suit[round.trump_suit] == round.trump_suit
      end

      def partner_winning?
        partner == trick.ranked_players.first
      end
    end
  end
end
