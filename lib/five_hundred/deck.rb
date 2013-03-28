# encoding: UTF-8

module FiveHundred
  class Deck
    attr_reader :cards

    def initialize
      @cards = Deck.set_of_cards.shuffle
    end

    def deal(num=10)
      @cards.slice!(0...num)
    end

  # class
    class << self; attr_accessor :card_definitions, :joker_special_definitions end

    @card_definitions = {
      "4d" => OpenStruct.new(
        code: "4d",
        rank: {
          none: { nil => 4, spades: 0, clubs: 0, diamonds: 4, hearts: 0 },
          misere: { nil => 4, spades: 0, clubs: 0, diamonds: 4, hearts: 0 },
          spades: { nil => 4, spades: 0, clubs: 0, diamonds: 4, hearts: 0 },
          clubs: { nil => 4, spades: 0, clubs: 0, diamonds: 4, hearts: 0 },
          diamonds: Hash.new(18),
          hearts: { nil => 4, spades: 0, clubs: 0, diamonds: 4, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "4h" => OpenStruct.new(
        code: "4h",
        rank: {
          none: { nil => 4, spades: 0, clubs: 0, diamonds: 0, hearts: 4 },
          misere: { nil => 4, spades: 0, clubs: 0, diamonds: 0, hearts: 4 },
          spades: { nil => 4, spades: 0, clubs: 0, diamonds: 0, hearts: 4 },
          clubs: { nil => 4, spades: 0, clubs: 0, diamonds: 0, hearts: 4 },
          diamonds: { nil => 4, spades: 0, clubs: 0, diamonds: 0, hearts: 4 },
          hearts: Hash.new(18),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "5s" => OpenStruct.new(
        code: "5s",
        rank: {
          none: { nil => 5, spades: 5, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 5, spades: 5, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(19),
          clubs: { nil => 5, spades: 5, clubs: 0, diamonds: 0, hearts: 0 },
          diamonds: { nil => 5, spades: 5, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 5, spades: 5, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "5c" => OpenStruct.new(
        code: "5c",
        rank: {
          none: { nil => 5, spades: 0, clubs: 5, diamonds: 0, hearts: 0 },
          misere: { nil => 5, spades: 0, clubs: 5, diamonds: 0, hearts: 0 },
          spades: { nil => 5, spades: 0, clubs: 5, diamonds: 0, hearts: 0 },
          clubs: Hash.new(19),
          diamonds: { nil => 5, spades: 0, clubs: 5, diamonds: 0, hearts: 0 },
          hearts: { nil => 5, spades: 0, clubs: 5, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "5d" => OpenStruct.new(
        code: "5d",
        rank: {
          none: { nil => 5, spades: 0, clubs: 0, diamonds: 5, hearts: 0 },
          misere: { nil => 5, spades: 0, clubs: 0, diamonds: 5, hearts: 0 },
          spades: { nil => 5, spades: 0, clubs: 0, diamonds: 5, hearts: 0 },
          clubs: { nil => 5, spades: 0, clubs: 0, diamonds: 5, hearts: 0 },
          diamonds: Hash.new(19),
          hearts: { nil => 5, spades: 0, clubs: 0, diamonds: 5, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "5h" => OpenStruct.new(
        code: "5h",
        rank: {
          none: { nil => 5, spades: 0, clubs: 0, diamonds: 0, hearts: 5 },
          misere: { nil => 5, spades: 0, clubs: 0, diamonds: 0, hearts: 5 },
          spades: { nil => 5, spades: 0, clubs: 0, diamonds: 0, hearts: 5 },
          clubs: { nil => 5, spades: 0, clubs: 0, diamonds: 0, hearts: 5 },
          diamonds: { nil => 5, spades: 0, clubs: 0, diamonds: 0, hearts: 5 },
          hearts: Hash.new(19),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "6s" => OpenStruct.new(
        code: "6s",
        rank: {
          none: { nil => 6, spades: 6, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 6, spades: 6, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(20),
          clubs: { nil => 6, spades: 6, clubs: 0, diamonds: 0, hearts: 0 },
          diamonds: { nil => 6, spades: 6, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 6, spades: 6, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "6c" => OpenStruct.new(
        code: "6c",
        rank: {
          none: { nil => 6, spades: 0, clubs: 6, diamonds: 0, hearts: 0 },
          misere: { nil => 6, spades: 0, clubs: 6, diamonds: 0, hearts: 0 },
          spades: { nil => 6, spades: 0, clubs: 6, diamonds: 0, hearts: 0 },
          clubs: Hash.new(20),
          diamonds: { nil => 6, spades: 0, clubs: 6, diamonds: 0, hearts: 0 },
          hearts: { nil => 6, spades: 0, clubs: 6, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "6d" => OpenStruct.new(
        code: "6d",
        rank: {
          none: { nil => 6, spades: 0, clubs: 0, diamonds: 6, hearts: 0 },
          misere: { nil => 6, spades: 0, clubs: 0, diamonds: 6, hearts: 0 },
          spades: { nil => 6, spades: 0, clubs: 0, diamonds: 6, hearts: 0 },
          clubs: { nil => 6, spades: 0, clubs: 0, diamonds: 6, hearts: 0 },
          diamonds: Hash.new(20),
          hearts: { nil => 6, spades: 0, clubs: 0, diamonds: 6, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "6h" => OpenStruct.new(
        code: "6h",
        rank: {
          none: { nil => 6, spades: 0, clubs: 0, diamonds: 0, hearts: 6 },
          misere: { nil => 6, spades: 0, clubs: 0, diamonds: 0, hearts: 6 },
          spades: { nil => 6, spades: 0, clubs: 0, diamonds: 0, hearts: 6 },
          clubs: { nil => 6, spades: 0, clubs: 0, diamonds: 0, hearts: 6 },
          diamonds: { nil => 6, spades: 0, clubs: 0, diamonds: 0, hearts: 6 },
          hearts: Hash.new(20),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "7s" => OpenStruct.new(
        code: "7s",
        rank: {
          none: { nil => 7, spades: 7, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 7, spades: 7, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(21),
          clubs: { nil => 7, spades: 7, clubs: 0, diamonds: 0, hearts: 0 },
          diamonds: { nil => 7, spades: 7, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 7, spades: 7, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "7c" => OpenStruct.new(
        code: "7c",
        rank: {
          none: { nil => 7, spades: 0, clubs: 7, diamonds: 0, hearts: 0 },
          misere: { nil => 7, spades: 0, clubs: 7, diamonds: 0, hearts: 0 },
          spades: { nil => 7, spades: 0, clubs: 7, diamonds: 0, hearts: 0 },
          clubs: Hash.new(21),
          diamonds: { nil => 7, spades: 0, clubs: 7, diamonds: 0, hearts: 0 },
          hearts: { nil => 7, spades: 0, clubs: 7, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "7d" => OpenStruct.new(
        code: "7d",
        rank: {
          none: { nil => 7, spades: 0, clubs: 0, diamonds: 7, hearts: 0 },
          misere: { nil => 7, spades: 0, clubs: 0, diamonds: 7, hearts: 0 },
          spades: { nil => 7, spades: 0, clubs: 0, diamonds: 7, hearts: 0 },
          clubs: { nil => 7, spades: 0, clubs: 0, diamonds: 7, hearts: 0 },
          diamonds: Hash.new(21),
          hearts: { nil => 7, spades: 0, clubs: 0, diamonds: 7, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "7h" => OpenStruct.new(
        code: "7h",
        rank: {
          none: { nil => 7, spades: 0, clubs: 0, diamonds: 0, hearts: 7 },
          misere: { nil => 7, spades: 0, clubs: 0, diamonds: 0, hearts: 7 },
          spades: { nil => 7, spades: 0, clubs: 0, diamonds: 0, hearts: 7 },
          clubs: { nil => 7, spades: 0, clubs: 0, diamonds: 0, hearts: 7 },
          diamonds: { nil => 7, spades: 0, clubs: 0, diamonds: 0, hearts: 7 },
          hearts: Hash.new(21),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "8s" => OpenStruct.new(
        code: "8s",
        rank: {
          none: { nil => 8, spades: 8, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 8, spades: 8, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(22),
          clubs: { nil => 8, spades: 8, clubs: 0, diamonds: 0, hearts: 0 },
          diamonds: { nil => 8, spades: 8, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 8, spades: 8, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "8c" => OpenStruct.new(
        code: "8c",
        rank: {
          none: { nil => 8, spades: 0, clubs: 8, diamonds: 0, hearts: 0 },
          misere: { nil => 8, spades: 0, clubs: 8, diamonds: 0, hearts: 0 },
          spades: { nil => 8, spades: 0, clubs: 8, diamonds: 0, hearts: 0 },
          clubs: Hash.new(22),
          diamonds: { nil => 8, spades: 0, clubs: 8, diamonds: 0, hearts: 0 },
          hearts: { nil => 8, spades: 0, clubs: 8, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "8d" => OpenStruct.new(
        code: "8d",
        rank: {
          none: { nil => 8, spades: 0, clubs: 0, diamonds: 8, hearts: 0 },
          misere: { nil => 8, spades: 0, clubs: 0, diamonds: 8, hearts: 0 },
          spades: { nil => 8, spades: 0, clubs: 0, diamonds: 8, hearts: 0 },
          clubs: { nil => 8, spades: 0, clubs: 0, diamonds: 8, hearts: 0 },
          diamonds: Hash.new(22),
          hearts: { nil => 8, spades: 0, clubs: 0, diamonds: 8, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "8h" => OpenStruct.new(
        code: "8h",
        rank: {
          none: { nil => 8, spades: 0, clubs: 0, diamonds: 0, hearts: 8 },
          misere: { nil => 8, spades: 0, clubs: 0, diamonds: 0, hearts: 8 },
          spades: { nil => 8, spades: 0, clubs: 0, diamonds: 0, hearts: 8 },
          clubs: { nil => 8, spades: 0, clubs: 0, diamonds: 0, hearts: 8 },
          diamonds: { nil => 8, spades: 0, clubs: 0, diamonds: 0, hearts: 8 },
          hearts: Hash.new(22),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "9s" => OpenStruct.new(
        code: "9s",
        rank: {
          none: { nil => 9, spades: 9, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 9, spades: 9, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(23),
          clubs: { nil => 9, spades: 9, clubs: 0, diamonds: 0, hearts: 0 },
          diamonds: { nil => 9, spades: 9, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 9, spades: 9, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "9c" => OpenStruct.new(
        code: "9c",
        rank: {
          none: { nil => 9, spades: 0, clubs: 9, diamonds: 0, hearts: 0 },
          misere: { nil => 9, spades: 0, clubs: 9, diamonds: 0, hearts: 0 },
          spades: { nil => 9, spades: 0, clubs: 9, diamonds: 0, hearts: 0 },
          clubs: Hash.new(23),
          diamonds: { nil => 9, spades: 0, clubs: 9, diamonds: 0, hearts: 0 },
          hearts: { nil => 9, spades: 0, clubs: 9, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "9d" => OpenStruct.new(
        code: "9d",
        rank: {
          none: { nil => 9, spades: 0, clubs: 0, diamonds: 9, hearts: 0 },
          misere: { nil => 9, spades: 0, clubs: 0, diamonds: 9, hearts: 0 },
          spades: { nil => 9, spades: 0, clubs: 0, diamonds: 9, hearts: 0 },
          clubs: { nil => 9, spades: 0, clubs: 0, diamonds: 9, hearts: 0 },
          diamonds: Hash.new(23),
          hearts: { nil => 9, spades: 0, clubs: 0, diamonds: 9, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "9h" => OpenStruct.new(
        code: "9h",
        rank: {
          none: { nil => 9, spades: 0, clubs: 0, diamonds: 0, hearts: 9 },
          misere: { nil => 9, spades: 0, clubs: 0, diamonds: 0, hearts: 9 },
          spades: { nil => 9, spades: 0, clubs: 0, diamonds: 0, hearts: 9 },
          clubs: { nil => 9, spades: 0, clubs: 0, diamonds: 0, hearts: 9 },
          diamonds: { nil => 9, spades: 0, clubs: 0, diamonds: 0, hearts: 9 },
          hearts: Hash.new(23),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "10s" => OpenStruct.new(
        code: "10s",
        rank: {
          none: { nil => 10, spades: 10, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 10, spades: 10, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(24),
          clubs: { nil => 10, spades: 10, clubs: 0, diamonds: 0, hearts: 0 },
          diamonds: { nil => 10, spades: 10, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 10, spades: 10, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "10c" => OpenStruct.new(
        code: "10c",
        rank: {
          none: { nil => 10, spades: 0, clubs: 10, diamonds: 0, hearts: 0 },
          misere: { nil => 10, spades: 0, clubs: 10, diamonds: 0, hearts: 0 },
          spades: { nil => 10, spades: 0, clubs: 10, diamonds: 0, hearts: 0 },
          clubs: Hash.new(24),
          diamonds: { nil => 10, spades: 0, clubs: 10, diamonds: 0, hearts: 0 },
          hearts: { nil => 10, spades: 0, clubs: 10, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "10d" => OpenStruct.new(
        code: "10d",
        rank: {
          none: { nil => 10, spades: 0, clubs: 0, diamonds: 10, hearts: 0 },
          misere: { nil => 10, spades: 0, clubs: 0, diamonds: 10, hearts: 0 },
          spades: { nil => 10, spades: 0, clubs: 0, diamonds: 10, hearts: 0 },
          clubs: { nil => 10, spades: 0, clubs: 0, diamonds: 10, hearts: 0 },
          diamonds: Hash.new(24),
          hearts: { nil => 10, spades: 0, clubs: 0, diamonds: 10, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "10h" => OpenStruct.new(
        code: "10h",
        rank: {
          none: { nil => 10, spades: 0, clubs: 0, diamonds: 0, hearts: 10 },
          misere: { nil => 10, spades: 0, clubs: 0, diamonds: 0, hearts: 10 },
          spades: { nil => 10, spades: 0, clubs: 0, diamonds: 0, hearts: 10 },
          clubs: { nil => 10, spades: 0, clubs: 0, diamonds: 0, hearts: 10 },
          diamonds: { nil => 10, spades: 0, clubs: 0, diamonds: 0, hearts: 10 },
          hearts: Hash.new(24),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Js" => OpenStruct.new(
        code: "Js",
        rank: {
          none: { nil => 11, spades: 11, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 11, spades: 11, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(30),
          clubs: Hash.new(29),
          diamonds: { nil => 11, spades: 11, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 11, spades: 11, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades).merge({ clubs: :clubs }),
        left_bower?: Hash.new(false).merge({ clubs: true }),
        right_bower?: Hash.new(false).merge({ spades: true }),
        joker?: false
      ),
      "Jc" => OpenStruct.new(
        code: "Jc",
        rank: {
          none: { nil => 11, spades: 0, clubs: 11, diamonds: 0, hearts: 0 },
          misere: { nil => 11, spades: 0, clubs: 11, diamonds: 0, hearts: 0 },
          spades: Hash.new(29),
          clubs: Hash.new(30),
          diamonds: { nil => 11, spades: 0, clubs: 11, diamonds: 0, hearts: 0 },
          hearts: { nil => 11, spades: 0, clubs: 11, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs).merge({ spades: :spades }),
        left_bower?: Hash.new(false).merge({ spades: true }),
        right_bower?: Hash.new(false).merge({ clubs: true }),
        joker?: false
      ),
      "Jd" => OpenStruct.new(
        code: "Jd",
        rank: {
          none: { nil => 11, spades: 0, clubs: 0, diamonds: 11, hearts: 0 },
          misere: { nil => 11, spades: 0, clubs: 0, diamonds: 11, hearts: 0 },
          spades: { nil => 11, spades: 0, clubs: 0, diamonds: 11, hearts: 0 },
          clubs: { nil => 11, spades: 0, clubs: 0, diamonds: 11, hearts: 0 },
          diamonds: Hash.new(30),
          hearts: Hash.new(29),
        },
        suit: Hash.new(:diamonds).merge({ hearts: :hearts }),
        left_bower?: Hash.new(false).merge({ hearts: true }),
        right_bower?: Hash.new(false).merge({ diamonds: true }),
        joker?: false
      ),
      "Jh" => OpenStruct.new(
        code: "Jh",
        rank: {
          none: { nil => 11, spades: 0, clubs: 0, diamonds: 0, hearts: 11 },
          misere: { nil => 11, spades: 0, clubs: 0, diamonds: 0, hearts: 11 },
          spades: { nil => 11, spades: 0, clubs: 0, diamonds: 0, hearts: 11 },
          clubs: { nil => 11, spades: 0, clubs: 0, diamonds: 0, hearts: 11 },
          diamonds: Hash.new(29),
          hearts: Hash.new(30),
        },
        suit: Hash.new(:hearts).merge({ diamonds: :diamonds }),
        left_bower?: Hash.new(false).merge({ diamonds: true }),
        right_bower?: Hash.new(false).merge({ hearts: true }),
        joker?: false
      ),
      "Qs" => OpenStruct.new(
        code: "Qs",
        rank: {
          none: { nil => 12, spades: 12, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 12, spades: 12, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(26),
          clubs: { nil => 12, spades: 12, clubs: 0, diamonds: 0, hearts: 0 },
          diamonds: { nil => 12, spades: 12, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 12, spades: 12, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Qc" => OpenStruct.new(
        code: "Qc",
        rank: {
          none: { nil => 12, spades: 0, clubs: 12, diamonds: 0, hearts: 0 },
          misere: { nil => 12, spades: 0, clubs: 12, diamonds: 0, hearts: 0 },
          spades: { nil => 12, spades: 0, clubs: 12, diamonds: 0, hearts: 0 },
          clubs: Hash.new(26),
          diamonds: { nil => 12, spades: 0, clubs: 12, diamonds: 0, hearts: 0 },
          hearts: { nil => 12, spades: 0, clubs: 12, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Qd" => OpenStruct.new(
        code: "Qd",
        rank: {
          none: { nil => 12, spades: 0, clubs: 0, diamonds: 12, hearts: 0 },
          misere: { nil => 12, spades: 0, clubs: 0, diamonds: 12, hearts: 0 },
          spades: { nil => 12, spades: 0, clubs: 0, diamonds: 12, hearts: 0 },
          clubs: { nil => 12, spades: 0, clubs: 0, diamonds: 12, hearts: 0 },
          diamonds: Hash.new(26),
          hearts: { nil => 12, spades: 0, clubs: 0, diamonds: 12, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Qh" => OpenStruct.new(
        code: "Qh",
        rank: {
          none: { nil => 12, spades: 0, clubs: 0, diamonds: 0, hearts: 12 },
          misere: { nil => 12, spades: 0, clubs: 0, diamonds: 0, hearts: 12 },
          spades: { nil => 12, spades: 0, clubs: 0, diamonds: 0, hearts: 12 },
          clubs: { nil => 12, spades: 0, clubs: 0, diamonds: 0, hearts: 12 },
          diamonds: { nil => 12, spades: 0, clubs: 0, diamonds: 0, hearts: 12 },
          hearts: Hash.new(26),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Ks" => OpenStruct.new(
        code: "Ks",
        rank: {
          none: { nil => 13, spades: 13, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 13, spades: 13, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(27),
          clubs: { nil => 13, spades: 13, clubs: 0, diamonds: 0, hearts: 0 },
          diamonds: { nil => 13, spades: 13, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 13, spades: 13, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Kc" => OpenStruct.new(
        code: "Kc",
        rank: {
          none: { nil => 13, spades: 0, clubs: 13, diamonds: 0, hearts: 0 },
          misere: { nil => 13, spades: 0, clubs: 13, diamonds: 0, hearts: 0 },
          spades: { nil => 13, spades: 0, clubs: 13, diamonds: 0, hearts: 0 },
          clubs: Hash.new(27),
          diamonds: { nil => 13, spades: 0, clubs: 13, diamonds: 0, hearts: 0 },
          hearts: { nil => 13, spades: 0, clubs: 13, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Kd" => OpenStruct.new(
        code: "Kd",
        rank: {
          none: { nil => 13, spades: 0, clubs: 0, diamonds: 13, hearts: 0 },
          misere: { nil => 13, spades: 0, clubs: 0, diamonds: 13, hearts: 0 },
          spades: { nil => 13, spades: 0, clubs: 0, diamonds: 13, hearts: 0 },
          clubs: { nil => 13, spades: 0, clubs: 0, diamonds: 13, hearts: 0 },
          diamonds: Hash.new(27),
          hearts: { nil => 13, spades: 0, clubs: 0, diamonds: 13, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Kh" => OpenStruct.new(
        code: "Kh",
        rank: {
          none: { nil => 13, spades: 0, clubs: 0, diamonds: 0, hearts: 13 },
          misere: { nil => 13, spades: 0, clubs: 0, diamonds: 0, hearts: 13 },
          spades: { nil => 13, spades: 0, clubs: 0, diamonds: 0, hearts: 13 },
          clubs: { nil => 13, spades: 0, clubs: 0, diamonds: 0, hearts: 13 },
          diamonds: { nil => 13, spades: 0, clubs: 0, diamonds: 0, hearts: 13 },
          hearts: Hash.new(27),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "As" => OpenStruct.new(
        code: "As",
        rank: {
          none: { nil => 14, spades: 14, clubs: 0, diamonds: 0, hearts: 0 },
          misere: { nil => 14, spades: 14, clubs: 0, diamonds: 0, hearts: 0 },
          spades: Hash.new(28),
          clubs: { nil => 14, spades: 14, clubs: 0, diamonds: 0, hearts: 0 },
          diamonds: { nil => 14, spades: 14, clubs: 0, diamonds: 0, hearts: 0 },
          hearts: { nil => 14, spades: 14, clubs: 0, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:spades),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Ac" => OpenStruct.new(
        code: "Ac",
        rank: {
          none: { nil => 14, spades: 0, clubs: 14, diamonds: 0, hearts: 0 },
          misere: { nil => 14, spades: 0, clubs: 14, diamonds: 0, hearts: 0 },
          spades: { nil => 14, spades: 0, clubs: 14, diamonds: 0, hearts: 0 },
          clubs: Hash.new(28),
          diamonds: { nil => 14, spades: 0, clubs: 14, diamonds: 0, hearts: 0 },
          hearts: { nil => 14, spades: 0, clubs: 14, diamonds: 0, hearts: 0 },
        },
        suit: Hash.new(:clubs),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Ad" => OpenStruct.new(
        code: "Ad",
        rank: {
          none: { nil => 14, spades: 0, clubs: 0, diamonds: 14, hearts: 0 },
          misere: { nil => 14, spades: 0, clubs: 0, diamonds: 14, hearts: 0 },
          spades: { nil => 14, spades: 0, clubs: 0, diamonds: 14, hearts: 0 },
          clubs: { nil => 14, spades: 0, clubs: 0, diamonds: 14, hearts: 0 },
          diamonds: Hash.new(28),
          hearts: { nil => 14, spades: 0, clubs: 0, diamonds: 14, hearts: 0 },
        },
        suit: Hash.new(:diamonds),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Ah" => OpenStruct.new(
        code: "Ah",
        rank: {
          none: { nil => 14, spades: 0, clubs: 0, diamonds: 0, hearts: 14 },
          misere: { nil => 14, spades: 0, clubs: 0, diamonds: 0, hearts: 14 },
          spades: { nil => 14, spades: 0, clubs: 0, diamonds: 0, hearts: 14 },
          clubs: { nil => 14, spades: 0, clubs: 0, diamonds: 0, hearts: 14 },
          diamonds: { nil => 14, spades: 0, clubs: 0, diamonds: 0, hearts: 14 },
          hearts: Hash.new(28),
        },
        suit: Hash.new(:hearts),
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: false
      ),
      "Jo" => OpenStruct.new(
        code: "Jo",
        rank: Hash.new(Hash.new(31)),
        suit: { nil => :none, none: :none, spades: :spades, clubs: :clubs, diamonds: :diamonds, hearts: :hearts },
        left_bower?: Hash.new(false),
        right_bower?: Hash.new(false),
        joker?: true,
        variations: {
          spades: OpenStruct.new(
            code: "Jo",
            rank: Hash.new(Hash.new(31)),
            suit: Hash.new(:spades),
            left_bower?: Hash.new(false),
            right_bower?: Hash.new(false),
            joker?: true
          ),
          clubs: OpenStruct.new(
            code: "Jo",
            rank: Hash.new(Hash.new(31)),
            suit: Hash.new(:clubs),
            left_bower?: Hash.new(false),
            right_bower?: Hash.new(false),
            joker?: true
          ),
          diamonds: OpenStruct.new(
            code: "Jo",
            rank: Hash.new(Hash.new(31)),
            suit: Hash.new(:diamonds),
            left_bower?: Hash.new(false),
            right_bower?: Hash.new(false),
            joker?: true
          ),
          hearts: OpenStruct.new(
            code: "Jo",
            rank: Hash.new(Hash.new(31)),
            suit: Hash.new(:hearts),
            left_bower?: Hash.new(false),
            right_bower?: Hash.new(false),
            joker?: true
          ),
        }
      )
    }

    def self.set_of_cards(suit=nil, trump_suit=nil)
      cards = []

      Deck.card_definitions.each do |key, val|
        card = Deck.card(key)
        cards << card if card.suit[trump_suit] == suit || suit.nil?
      end

      cards
    end

    def self.card(code)
      Deck.card_definitions[code]
    end

    def self.cards(codes)
      cards = []
      codes.each do |c|
        cards << Deck.card(c)
      end

      cards
    end
  end
end
