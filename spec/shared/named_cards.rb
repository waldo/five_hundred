# encoding: UTF-8
require "spec_helper"

shared_context "named cards" do
  before do
    @four_diamonds  = Deck.card("4d")
    @four_hearts    = Deck.card("4h")

    @five_spades    = Deck.card("5s")
    @five_clubs     = Deck.card("5c")
    @five_diamonds  = Deck.card("5d")
    @five_hearts    = Deck.card("5h")

    @six_spades     = Deck.card("6s")
    @six_clubs      = Deck.card("6c")
    @six_diamonds   = Deck.card("6d")
    @six_hearts     = Deck.card("6h")

    @seven_spades   = Deck.card("7s")
    @seven_clubs    = Deck.card("7c")
    @seven_diamonds = Deck.card("7d")
    @seven_hearts   = Deck.card("7h")

    @eight_spades   = Deck.card("8s")
    @eight_clubs    = Deck.card("8c")
    @eight_diamonds = Deck.card("8d")
    @eight_hearts   = Deck.card("8h")

    @nine_spades    = Deck.card("9s")
    @nine_clubs     = Deck.card("9c")
    @nine_diamonds  = Deck.card("9d")
    @nine_hearts    = Deck.card("9h")

    @ten_spades     = Deck.card("10s")
    @ten_clubs      = Deck.card("10c")
    @ten_diamonds   = Deck.card("10d")
    @ten_hearts     = Deck.card("10h")

    @jack_spades    = Deck.card("Js")
    @jack_clubs     = Deck.card("Jc")
    @jack_diamonds  = Deck.card("Jd")
    @jack_hearts    = Deck.card("Jh")

    @queen_spades   = Deck.card("Qs")
    @queen_clubs    = Deck.card("Qc")
    @queen_diamonds = Deck.card("Qd")
    @queen_hearts   = Deck.card("Qh")

    @king_spades    = Deck.card("Ks")
    @king_clubs     = Deck.card("Kc")
    @king_diamonds  = Deck.card("Kd")
    @king_hearts    = Deck.card("Kh")

    @ace_spades     = Deck.card("As")
    @ace_clubs      = Deck.card("Ac")
    @ace_diamonds   = Deck.card("Ad")
    @ace_hearts     = Deck.card("Ah")

    @joker          = Deck.card("Jo")
  end
end