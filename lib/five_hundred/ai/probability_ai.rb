# encoding: UTF-8
require "five_hundred/player"

module FiveHundred
  module AI
    class ProbabilityAI < OrderedAI
      def request_play
        top_card = @r.remaining_rank_ordered_cards.first
        # return highest ranked card (if you have it)
        if @r.valid_cards.include?(top_card)
          return top_card
        end
        # return lowest ranked card
        @r.valid_cards.sort_by{|c| c.rank(@r.trump_suit) }.first
      end

      def to_s
        "#{self.class} 0.1"
      end

      def probabilities
        slots = (0..3).to_a << :kitty
        probability_list = Hash.new {|h, k| h[k] = {} }

        slots.each do |slot|
          all_codes.each do |code|
            probability_list[slot][code] = assign_for_my_cards(slot, code) || assign_for_discarded_kitty_cards(slot, code) || assign_for_played_cards(slot, code) || assign_for_unknown_cards(slot, code)
          end
        end

        probability_list
      end

      def assign_for_my_cards(slot, code)
        if my_codes.include?(code)
          is_me?(slot) ? 1.0 : 0.0
        end
      end

      def assign_for_discarded_kitty_cards(slot, code)
        if discarded_kitty_codes.include?(code)
          is_kitty?(slot) ? 1.0 : 0.0
        end
      end

      def assign_for_played_cards(slot, code)
        known_codes.include?(code) ? 0.0 : nil
      end

      def assign_for_unknown_cards(slot, code)
        if is_me?(slot)
          0.0
        elsif is_kitty?(slot)
          me_seen_kitty?(slot) ? 0.0 : 3.0 / 33.0
        else
          10.0 / unknown_count
        end
      end

      def is_me?(slot)
        slot == @g.players.index(self)
      end
      private :is_me?

      def is_kitty?(slot)
        slot == :kitty
      end
      private :is_kitty?

      def me_seen_kitty?(slot)
        @r.winning_bidder == self
      end
      private :me_seen_kitty?

      def all_codes
        @codes = @codes || Deck.set_of_cards.map(&:code)
      end
      private :all_codes

      def all_count
        all_codes.count
      end
      private :all_count

      def my_codes
        (cards + kitty).map(&:code)
      end
      private :my_codes

      def discarded_kitty_codes
        discarded_kitty.map(&:code)
      end
      private :discarded_kitty_codes

      def known_codes
        (cards + kitty + discarded_kitty + @r.trick_set.all_played_cards).map(&:code)
      end
      private :known_codes

      def known_count
        known_codes.count
      end
      private :known_count

      def unknown_codes
        all_codes - known_codes
      end
      private :unknown_codes

      def unknown_count
        unknown_codes.count
      end
      private :unknown_count
    end
  end
end
