class Card
  attr_reader :code, :rank, :suit

  @@ace_rank = 14
  @@right_bower = 99
  @@left_bower = 98

  def initialize(code, rank, suit)
    @code = code
    @rank = rank
    @suit = suit
  end
  
  def card_value(led_suit, trump_suit)
    val = 0

    if (@suit == led_suit and suit != trump_suit) or joker?
      val = @rank
    elsif right_bower?(trump_suit)
      val = @@right_bower
    elsif left_bower?(trump_suit)
      val = @@left_bower
    elsif trump?(trump_suit)
      val = @rank + @@ace_rank
    end

    val
  end

  def joker?
    @code == "Jo"
  end

  def trump?(trump_suit)
    @suit == trump_suit
  end

  def right_bower?(trump_suit)
    @suit == trump_suit and @rank == 11
  end

  def left_bower?(trump_suit)
    bower_check(trump_suit, :spades, :clubs) or
    bower_check(trump_suit, :clubs, :spades) or
    bower_check(trump_suit, :diamonds, :hearts) or
    bower_check(trump_suit, :hearts, :diamonds)
  end

  def to_s
    "code: #{@code}, rank: #{@rank}, suit: #{suit}"
  end

  def ==(other)
    self.to_s == other.to_s
  end

private
  def bower_check(trump_suit, suit_a, suit_b)
    trump_suit == suit_a and @suit == suit_b and rank == 11
  end
end