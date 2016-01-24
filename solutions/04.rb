class Card < Struct.new(:rank, :suit)
  def to_s
    "#{rank.to_s.capitalize} of #{suit.to_s.capitalize}"
  end
end


class BaseDeck
  include Enumerable

  ALLOWED_SUITS = [:spades, :hearts, :diamonds, :clubs]
  ALLOWED_RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

  def initialize(deck = generate_default_deck)
    @deck = deck
  end

  def generate_default_deck
    deck = Array.new
    self.class::ALLOWED_RANKS.product(self.class::ALLOWED_SUITS)
        .each { |rank, suit| deck.push(Card.new(rank, suit)) }
    deck
  end

  public
  def each(&block)
    @deck.each(&block)
  end

  def size
    @deck.size
  end

  def draw_top_card
    @deck.shift
  end

  def draw_bottom_card
    @deck.pop
  end

  def top_card
    @deck.first
  end

  def bottom_card
    @deck.last
  end

  def shuffle
    @deck.shuffle!
  end

  def sort
    @deck.sort! { |x,y|
      suits_comp = compare_suits(x,y)
      suits_comp == 0 ? compare_ranks(y,x) : suits_comp
    }
  end

  def deal
    raise "NotImplementedError"
  end

  def to_s
    @deck.map(&:to_s).join("\n")
  end

  private
  def compare_suits(first, second)
    self.class::ALLOWED_SUITS.find_index(first.suit) <=>
    self.class::ALLOWED_SUITS.find_index(second.suit)
  end

  def compare_ranks(first, second)
    self.class::ALLOWED_RANKS.find_index(first.rank) <=>
    self.class::ALLOWED_RANKS.find_index(second.rank)
  end
end


class WarDeck < BaseDeck
  CARDS_IN_HAND = 26
  def deal
    WarHand.new(@deck.take(CARDS_IN_HAND),
                self.class::ALLOWED_RANKS,
                self.class::ALLOWED_SUITS)
  end
end


class BeloteDeck < BaseDeck
  ALLOWED_RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]
  CARDS_IN_HAND  = 8
  def deal
    BeloteHand.new(@deck.take(CARDS_IN_HAND),
                   self.class::ALLOWED_RANKS,
                   self.class::ALLOWED_SUITS)
  end
end


class SixtySixDeck < BaseDeck
  ALLOWED_RANKS = [9, :jack, :queen, :king, 10, :ace]
  CARDS_IN_HAND = 6
  def deal
    SixtySixHand.new(@deck.take(CARDS_IN_HAND),
                     self.class::ALLOWED_RANKS,
                     self.class::ALLOWED_SUITS)
  end
end


class Hand
  attr_reader :cards, :allowed_ranks, :allowed_suits

  def initialize(cards, allowed_ranks, allowed_suits)
    @cards = cards
    @allowed_ranks = allowed_ranks
    @allowed_suits = allowed_suits
  end

  def size
    @cards.length
  end

  def fetch_cards(ranks, exclude_suits = [])
    @cards.select{ |card| ranks.include? card.rank \
                      and not exclude_suits.include? card.suit }
  end

  def filter_cards_by_suit(cards, suit)
    cards.select{ |card| card.suit == suit }
  end

  def cards_exist_in_any_suite?(cards, length)
    cards.group_by { |card|
      card.suit
    }.select{ |_, cards|
      cards.length >= length }.length > 0
  end
end


class WarHand < Hand
  def play_card
    @cards.pop
  end

  def allow_face_up?
    @cards.length <= 3
  end
end


class BeloteHand < Hand
  def highest_of_suit(suit)
    @cards.select { |card|
      card.suit == suit
    }.max_by { |card|
      @allowed_ranks.find_index(card.rank)
    }
  end

  def belote?
    cards_exist_in_any_suite?(fetch_cards([:queen, :king]), 2)
  end

  def tierce?
    rank_sequence?(3)
  end

  def quarte?
    rank_sequence?(4)
  end

  def quint?
    rank_sequence?(5)
  end

  def carre_of_jacks?
    fetch_cards([:jack]).length == 4
  end

  def carre_of_nines?
    fetch_cards([9]).length == 4
  end

  def carre_of_aces?
    fetch_cards([:ace]).length == 4
  end

  private
  def rank_sequence?(length)
    allowed_ranks.each_cons(length).any? do |sequence|
      cards_exist_in_any_suite?(fetch_cards(sequence), length)
    end
  end
end


class SixtySixHand < Hand
  def twenty?(trump_suit)
    cards_exist_in_any_suite?(fetch_cards([:queen, :king], [trump_suit]), 2)
  end

  def forty?(trump_suit)
    filter_cards_by_suit(fetch_cards([:queen, :king]), trump_suit).length == 2
  end
end
