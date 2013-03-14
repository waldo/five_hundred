# encoding: UTF-8
require "spec_helper"

module FiveHundred
  module AI
    describe "ai" do
      include_context "game support"
      include_context "named bids"
      include_context "named cards"

      before do
        @ai = RuleAI.new

        players = Array.new(3) { Player.new }
        players += [@ai]

        build_game_stub(players)
        @round = double("Round").as_null_object

        @game.stub(:current_round).and_return(@round)
        @card_arr = [@joker, @jack_hearts, @jack_diamonds, @ace_hearts, @king_hearts, @queen_hearts, @ten_hearts, @nine_hearts, @eight_hearts, @seven_hearts]
        @round.stub(
          :highest_bid => @bid_10d,
          :trump_suit => :hearts,
          :valid_bids => [@bid_10d, @bid_10h, @bid_om, @bid_10nt, @pass],
          :valid_cards => @card_arr
        )

        @ai.game = @game
        @ai.assign_cards(@card_arr)
      end

      context "should respond to requests for" do
        it "bid with a valid bid from the suit it has with most cards" do
          bid = @ai.request(:bid)

          @round.valid_bids.should include(bid)
        end

        it "bid and be 10 or less" do
          @ai.request(:bid).should == @bid_10h
        end

        it "kitty with the 3 lowest cards from your hand" do
          cards = @ai.request(:kitty)

          cards.should == [@seven_hearts, @eight_hearts, @nine_hearts]
        end

        it "play with a card from your hand" do
          @round.stub(:current_trick => stub(:cards => []))
          card = @ai.request(:play)

          @ai.cards.should include(card)
          @round.valid_cards.should include(card)
        end

        context "(non-misere)" do
          subject { @ai.request_play }

          it "plays only valid choice" do
            @round.stub(:valid_cards => [@seven_hearts])

            should == @seven_hearts
          end

          context "multiple valid cards" do
            context "can't beat existing cards in the trick" do
              before do
                current_trick = stub(:cards => [@joker])
                @round.stub(:current_trick => current_trick)
              end

              it "plays low" do
                @round.stub(:valid_cards => [@jack_hearts, @ten_hearts])

                should == @ten_hearts
              end
            end

            context "can beat existing cards in the trick" do
              context "playing first" do
                before do
                  current_trick = stub(:cards => [], :players => [])
                  @round.stub(
                    :current_trick => current_trick,
                    :remaining_cards_plus_current_trick => [@joker, @jack_hearts, @jack_diamonds, @seven_hearts, @six_hearts],
                    :voided_suits => [],
                    :led_suit => nil
                  )
                end

                context "has a guaranteed winner" do
                  it "plays the guaranteed winner" do
                    @round.stub(:valid_cards => [@joker, @ten_hearts])

                    should == @joker
                  end
                end

                context "no guaranteed winner" do
                  context "has the highest card in a non-trumps suit and (opponents have cards in this suit or opponents lack trumps)" do
                    it "plays highest card in a suit" do
                      @round.stub(:remaining_cards).with(:spades).and_return([@ace_spades, @king_spades, @queen_spades, @ten_spades])
                      @round.stub(:remaining_cards).with(:clubs).and_return([@king_clubs, @ten_clubs])
                      @round.stub(:remaining_cards).with(:diamonds).and_return([])
                      @round.stub(:remaining_cards).with(:hearts).and_return([@joker])
                      @round.stub(:valid_cards => [@ace_spades, @ten_spades, @ten_clubs])

                      should == @ace_spades
                    end
                  end

                  context "otherwise" do
                    it "plays low" do
                      @round.stub(:remaining_cards).with(:spades).and_return([@ace_spades, @king_spades, @queen_spades, @ten_spades])
                      @round.stub(:remaining_cards).with(:clubs).and_return([@king_clubs, @ten_clubs])
                      @round.stub(:remaining_cards).with(:diamonds).and_return([])
                      @round.stub(:remaining_cards).with(:hearts).and_return([@joker])
                      @round.stub(:valid_cards => [@king_spades, @ten_spades, @ten_clubs])

                      should == @ten_clubs
                    end
                  end
                end
              end

              context "playing second / third shared" do
                before do
                  @current_trick = stub(:players => @game.players[0..rand(2)])
                  @ai.assign_cards([@queen_hearts, @six_hearts])
                end

                context "trumps are led" do
                  before { @current_trick.stub(:cards => [@ten_hearts]) }

                  it "plays highest" do
                    @round.stub(
                      :current_trick => @current_trick,
                      :valid_cards => [@queen_hearts, @six_hearts],
                      :trump_suit => :hearts,
                      :led_suit => :hearts
                    )
                    @round.stub(:remaining_cards).with(:hearts).and_return([@joker, @jack_hearts, @jack_diamonds, @queen_hearts, @ten_hearts, @six_hearts])

                    should == @queen_hearts
                  end
                end

                context "trumps are not led" do
                  before { @current_trick.stub(:cards => [@ten_clubs]) }

                  context "I can trump" do
                    it "I predict that opponents can't trump, so trump low" do
                      @round.stub(
                        :current_trick => @current_trick,
                        :valid_cards => [@queen_hearts, @six_hearts],
                        :trump_suit => :hearts,
                        :led_suit => :clubs,
                        :voided_suits => []
                      )
                      @round.stub(:remaining_cards).with(:hearts).and_return([@joker, @queen_hearts, @six_hearts])
                      @round.stub(:remaining_cards).with(:clubs).and_return([@ten_clubs])

                      should == @six_hearts
                    end

                    it "I predict that opponents can trump, so trump high" do
                      @round.stub(
                        :current_trick => @current_trick,
                        :valid_cards => [@queen_hearts, @six_hearts],
                        :trump_suit => :hearts,
                        :led_suit => :clubs,
                        :voided_suits => []
                      )
                      @round.stub(:remaining_cards).with(:hearts).and_return([@joker, @queen_hearts, @ten_hearts, @nine_hearts, @six_hearts])
                      @round.stub(:remaining_cards).with(:clubs).and_return([@ten_clubs])

                      should == @queen_hearts
                    end
                  end

                  context "I cannot trump" do
                    before { @ai.assign_cards([@king_clubs, @six_clubs]) }

                    it "play highest" do
                      @current_trick.stub(:cards => [@jack_clubs, @ten_clubs])
                      @round.stub(
                        :current_trick => @current_trick,
                        :valid_cards => [@king_clubs, @six_clubs],
                        :trump_suit => :hearts,
                        :led_suit => :clubs,
                        :voided_suits => [],
                        :remaining_cards_plus_current_trick => [@ace_clubs, @king_clubs, @queen_clubs, @jack_clubs, @ten_clubs, @six_clubs]
                      )
                      @round.stub(:card_played_by).with(@ai.partner).and_return(@jack_clubs)
                      @round.stub(:remaining_cards).with(:clubs).and_return([@ace_clubs, @king_clubs, @queen_clubs, @jack_clubs, @ten_clubs, @six_clubs])

                      should == @king_clubs
                    end
                  end
                end
              end

              context "playing third initial strategy" do
                before { @current_trick = stub(:players => @game.players[0..1], :cards => [@ten_clubs, @queen_clubs]) }

                it "my partner played a guaranteed winner (excluding my cards) so play low" do
                  @ai.assign_cards([@ace_clubs, @six_clubs])
                  @round.stub(
                    :current_trick => @current_trick,
                    :valid_cards => [@ace_clubs, @six_clubs],
                    :trump_suit => :hearts,
                    :led_suit => :clubs,
                    :voided_suits => [],
                    :remaining_cards_plus_current_trick => [@ace_clubs, @queen_clubs, @jack_clubs, @ten_clubs, @six_clubs]
                  )
                  @round.stub(:card_played_by).with(@ai.partner).and_return(@queen_clubs)

                  should == @six_clubs
                end

                it "my top card is equivalent my partner's card so play low" do
                  @ai.assign_cards([@king_clubs, @six_clubs])
                  @round.stub(
                    :current_trick => @current_trick,
                    :valid_cards => [@king_clubs, @six_clubs],
                    :trump_suit => :hearts,
                    :led_suit => :clubs,
                    :voided_suits => [],
                    :remaining_cards_plus_current_trick => [@ace_clubs, @king_clubs, @queen_clubs, @ten_clubs, @six_clubs, @six_clubs]
                  )
                  @round.stub(:remaining_cards).with(:clubs).and_return([@ace_clubs, @king_clubs, @six_clubs])
                  @round.stub(:card_played_by).with(@ai.partner).and_return(@queen_clubs)

                  should == @six_clubs
                end

                it "otherwise play second / third shared strategy" do
                  @round.stub(
                    :current_trick => @current_trick,
                    :valid_cards => [@ace_clubs, @six_clubs],
                    :trump_suit => :hearts,
                    :led_suit => :clubs,
                    :voided_suits => [],
                    :remaining_cards_plus_current_trick => [@ace_clubs, @king_clubs, @queen_clubs, @ten_clubs, @six_clubs]
                  )
                  @round.stub(:card_played_by).with(@ai.partner).and_return(@queen_clubs)

                  @ai.should_receive(:playing_common_second_or_third)
                  @ai.request_play
                end
              end

              context "playing fourth" do
                before { @current_trick = stub(:players => @game.players[0..2]) }

                context "partner is winning" do
                  it "plays low" do
                    @current_trick.stub(:cards => [@ten_clubs, @queen_clubs, @jack_clubs])
                    @ai.assign_cards([@joker, @six_spades])
                    @round.stub(
                      :current_trick => @current_trick,
                      :valid_cards => [@joker, @six_spades],
                      :trump_suit => :hearts,
                      :led_suit => :clubs,
                      :voided_suits => [],
                      :remaining_cards_plus_current_trick => [@joker, @king_clubs, @queen_clubs, @jack_clubs, @ten_clubs, @six_clubs, @six_spades]
                    )
                    @round.stub(:card_played_by).with(@ai.partner).and_return(@queen_clubs)

                    should == @six_spades
                  end
                end

                context "otherwise" do
                  it "plays lowest winner" do
                    @current_trick.stub(:cards => [@ten_clubs, @jack_clubs, @queen_clubs])
                    @ai.assign_cards([@joker, @six_hearts, @six_spades])
                    @round.stub(
                      :current_trick => @current_trick,
                      :valid_cards => [@joker, @six_hearts, @six_spades],
                      :trump_suit => :hearts,
                      :led_suit => :clubs,
                      :voided_suits => [],
                      :remaining_cards_plus_current_trick => [@joker, @king_clubs, @queen_clubs, @jack_clubs, @ten_clubs, @six_clubs, @six_hearts, @six_spades]
                    )
                    @round.stub(:card_played_by).with(@ai.partner).and_return(@jack_clubs)

                    should == @six_hearts
                  end
                end
              end
            end
          end
        end
      end

      describe "one valid choice" do
        subject { @ai.one_valid_choice? }
        it "returns true when only one cards is valid" do
          @round.stub(:valid_cards => [@seven_hearts])

          should be_true
        end

        it "returns false when multiple cards are valid" do
          @round.stub(:valid_cards => [@seven_hearts, @six_spades, @six_clubs])

          should be_false
        end
      end

      describe "can I beat existing cards already in the trick?" do
        subject { @ai.winnable_trick? }
        before do
          current_trick = stub(:cards => [@six_hearts])
          @round.stub(:current_trick => current_trick)
        end

        it "returns true given I have a higher ranked card than those in the trick" do
          @round.stub(:valid_cards => [@seven_hearts, @six_spades, @six_clubs])

          should be_true
        end

        it "returns false given I have only lower ranked cards than those in the trick" do
          @round.stub(:valid_cards => [@five_hearts, @six_spades, @six_clubs])

          should be_false
        end
      end

      describe "guaranteed winner?" do
        subject { @ai.guaranteed_winner? }

        before do
          @round.stub(:remaining_cards_plus_current_trick => [@jack_hearts, @jack_diamonds, @seven_hearts, @six_hearts])
        end

        it "returns true if the set includes the strongest remaining card" do
          @round.stub(:valid_cards => [@jack_hearts, @seven_hearts])

          should be_true
        end

        it "returns false if the set doesn't include the strongest remaining card" do
          @round.stub(:valid_cards => [@jack_diamonds, @seven_hearts])

          should be_false
        end
      end

      describe "highest in a non-trump suit" do
        it "returns each highest non-trump card that I have" do
          @round.stub(:valid_cards => [@ace_clubs, @king_diamonds, @king_clubs, @joker, @king_spades])

          @round.stub(:remaining_cards).with(:spades).and_return([@king_spades])
          @round.stub(:remaining_cards).with(:clubs).and_return([@ace_clubs])
          @round.stub(:remaining_cards).with(:diamonds).and_return([@ace_diamonds])

          @round.should_not_receive(:remaining_cards).with(:hearts)
          @ai.top_cards_non_trump_suit.should == [@king_spades, @ace_clubs]
        end

        it "returns empty array if I don't have any high cards" do
          @ai.assign_cards([@queen_clubs, @king_diamonds, @king_clubs, @joker, @jack_spades])

          @round.stub(:remaining_cards).with(:spades).and_return([@king_spades])
          @round.stub(:remaining_cards).with(:clubs).and_return([@ace_clubs])
          @round.stub(:remaining_cards).with(:diamonds).and_return([@ace_diamonds])

          @round.should_not_receive(:remaining_cards).with(:hearts)
          @ai.top_cards_non_trump_suit.should == []
        end
      end

      describe "guess if a player has this suit" do
        subject { @ai.guess_player_has_suit?(@players[0], :clubs) }

        it "returns false if other player has voided this suit" do
          @round.stub(:voided_suits).with(@players[0]).and_return([:clubs, :spades])

          should be_false
        end

        context "other players haven't voided this suit" do
          before do
            @round.stub(:voided_suits).with(@players[0]).and_return([:spades])
            @round.stub(:remaining_cards).with(:clubs).and_return([@king_clubs, @queen_clubs, @jack_clubs, @ten_clubs])
          end

          it "returns false if less than 3 cards in this suit remain in unknown positions" do
            @ai.assign_cards([@king_clubs, @queen_clubs])

            should be_false
          end

          it "returns true if 3 or more cards in this suit remain in unknown positions" do
            @ai.assign_cards([])

            should be_true
          end
        end
      end

      describe "has my partner played a guaranteed winner?" do
        subject { @ai.partner_played_guaranteed_winner? }

        before do
          @round.stub(:remaining_cards_plus_current_trick => [@ace_clubs, @king_clubs, @queen_clubs, @jack_clubs, @ten_clubs])
        end

        it "returns true if partner played the top card" do
          @round.stub(:card_played_by).with(@ai.partner).and_return(@ace_clubs)

          should be_true
        end

        it "returns false if partner played any other card" do
          @round.stub(:card_played_by).with(@ai.partner).and_return(@king_clubs)

          should be_false
        end

        context "excluding my cards" do
          before { @ai.assign_cards([@ace_clubs, @king_clubs]) }

          it "returns true if partner played the top card excluding my cards" do
            @round.stub(:card_played_by).with(@ai.partner).and_return(@queen_clubs)

            should be_true
          end
        end
      end

      describe "my top card is equivalent to my partner's played card?" do
        subject { @ai.top_card_equivalent_to_partners_card? }

        before { @round.stub(:card_played_by).with(@ai.partner).and_return(@ten_clubs) }

        context "partner card is 10C and my card is JC" do
          it "returns true" do
            @ai.assign_cards([@jack_clubs])
            @round.stub(
              :valid_cards => [@jack_clubs],
              :remaining_cards_plus_current_trick => [@king_clubs, @queen_clubs, @jack_clubs, @ten_clubs, @six_clubs]
            )

            should be_true
          end
        end

        context "partner card is 10C and my card is AC (when JC, QC and KC have already been played)" do
          it "returns true" do
            @ai.assign_cards([@ace_clubs])
            @round.stub(
              :valid_cards => [@ace_clubs],
              :remaining_cards_plus_current_trick => [@ace_clubs, @ten_clubs, @six_clubs]
            )

            should be_true
          end
        end

        context "partner card is 10C and my card is QC (when I have JC too)" do
          it "returns true" do
            @ai.assign_cards([@queen_clubs, @jack_clubs])
            @round.stub(
              :valid_cards => [@queen_clubs, @jack_clubs],
              :remaining_cards_plus_current_trick => [@queen_clubs, @jack_clubs, @ten_clubs, @six_clubs]
            )

            should be_true
          end
        end

        context "partner card is 10C and my card is QC (when JC has not been played)" do
          it "returns false" do
            @ai.assign_cards([@queen_clubs])
            @round.stub(
              :valid_cards => [@queen_clubs],
              :remaining_cards_plus_current_trick => [@king_clubs, @queen_clubs, @jack_clubs, @ten_clubs, @six_clubs]
            )

            should be_false
          end
        end
      end

      describe "has trumps been led?" do
        subject { @ai.trump_suit_led? }

        it "returns true if a trump is led" do
          @round.stub(:led_suit => :hearts)

          should be_true
        end

        it "returns false if a non-trump card is led" do
          @round.stub(:led_suit => :clubs)

          should be_false
        end
      end

      describe "can I trump?" do
        subject { @ai.can_use_trump? }

        it "returns true if I have trumps valid for this trick" do
          @round.stub(:valid_cards => [@seven_hearts, @six_spades, @six_clubs])

          should be_true
        end

        it "returns false if I have no trumps valid for this trick" do
          @round.stub(:valid_cards => [@six_spades, @six_clubs])

          should be_false
        end
      end

      describe "is my partner winning?" do
        subject { @ai.partner_winning_trick? }

        before do
          current_trick = stub(:cards => [@seven_hearts, @six_hearts, @five_hearts])
          @round.stub(:current_trick => current_trick)
        end

        it "returns true if your partner played the highest card in the trick" do
          @round.stub(:card_played_by).with(@ai.partner).and_return(@seven_hearts)

          should be_true
        end

        it "returns false if your partner's card isn't the highest in the trick" do
          @round.stub(:card_played_by).with(@ai.partner).and_return(@six_hearts)

          should be_false
        end

        it "returns false if your partner hasn't played yet" do
          @round.stub(:card_played_by).with(@ai.partner).and_return(nil)

          should be_false
        end
      end

# actions
      describe "play highest card in a suit" do
      end

      describe "play highest card" do
        subject { @ai.play_highest }

        it "returns your highest ranked card" do
          @round.stub(:valid_cards => [@jack_diamonds, @seven_hearts, @eight_clubs])

          should == @jack_diamonds
        end
      end

      describe "play lowest winner" do
        subject { @ai.play_lowest_winner }

        before do
          @round.stub(:valid_cards => [@jack_diamonds, @seven_hearts, @eight_clubs])

          current_trick = stub(:cards => [@seven_clubs, @six_clubs, @six_hearts])
          @round.stub(:current_trick => current_trick)
        end

        it "returns a winning card lower than your highest ranked" do
          should == @seven_hearts
        end

        it "returns a winning card even if it's your highest ranked" do
          @round.stub(:valid_cards => [@seven_hearts, @eight_clubs])

          should == @seven_hearts
        end
      end

      describe "trump high" do
        subject { @ai.trump_high }

        before do
          @round.stub(:valid_cards => [@jack_diamonds, @seven_hearts, @eight_clubs])
        end

        it "returns your highest trump" do
          should == @jack_diamonds
        end
      end

      describe "trump low" do
        subject { @ai.trump_low }

        before do
          @round.stub(:valid_cards => [@jack_diamonds, @seven_hearts, @eight_clubs])
        end

        it "returns your lowest trump" do
          should == @seven_hearts
        end
      end

      describe "play low" do
        subject { @ai.play_low }

        context "multiple suits in valid choices including trumps" do
          it "plays lowest in the non-trump suit with fewest cards" do
            @round.stub(:valid_cards => [@seven_hearts, @eight_clubs, @seven_clubs, @eight_spades, @seven_spades, @six_spades])

            should == @seven_clubs
          end
        end

        it "plays your lowest ranked card" do
          @round.stub(:valid_cards => [@eight_clubs, @seven_clubs, @eight_spades, @seven_spades, @six_spades])

          should == @six_spades
        end
      end
    end
  end
end
