class InternalRational < Struct.new(:numerator, :denominator)
end


module DrunkenMathematician
  def prime?(number)
    return false if number == 1

    max_possible = Math.sqrt(number).floor
    (2..max_possible).each do |x|
      return false if number % x == 0
    end
    true
  end

  def meaningless(seq_length)
    rational_numbers = RationalSequence.new(seq_length).to_a
    group1, group2 = [], []
    rational_numbers.each do |x|
      if prime?(x.numerator) or prime?(x.denominator)
        group1.push(x)
      else
        group2.push(x)
      end
    end
    product1, product2 = group1.reduce(:*) || 1, group2.reduce(:*) || 1
    Rational(product1, product2)
  end

  def aimless(seq_length)
    prime_numbers = PrimeSequence.new(seq_length).to_a
    rational_numbers = []
    prime_numbers.each_slice(2) do |x|
      rational_numbers.push(Rational *x)
    end
    rational_numbers.reduce(:+) || 0
  end

  def worthless(seq_length)
    nth_fibonacci = FibonacciSequence.new(seq_length).to_a[-1] || 0
    i = 1
    while RationalSequence.new(i).reduce(:+) <= nth_fibonacci
      i += 1
    end
    i -= 1
    RationalSequence.new(i).to_a
  end

  module_function :prime?
  module_function :meaningless
  module_function :aimless
  module_function :worthless

end


module RationSequenceMovement
  def move(direction, rational)
    if direction == :up
      {numerator: rational.numerator - 1, denominator: rational.denominator + 1}
    else
      {numerator: rational.numerator + 1, denominator: rational.denominator - 1}
    end
  end

  def change_direction(direction, rational)
    if direction == :up
      {numerator: rational.numerator, denominator: rational.denominator + 1}
    else
      {numerator: rational.numerator + 1, denominator: rational.denominator}
    end
  end

  def is_in_direction(direction, rational)
    if direction == :up
      (rational.numerator - 1) > 0
    else
      (rational.denominator - 1) > 0
    end
  end

  def toggle_direction(direction)
    direction == :up ? :down : :up
  end
end


class RationalSequence
  include Enumerable
  include RationSequenceMovement

  def initialize(limit)
    @limit = limit
  end

  def each
    rational_number = InternalRational.new(1,1)
    current, direction = 0, :down
    while current < @limit
      yield Rational(rational_number.numerator,
                     rational_number.denominator)
      current += 1
      direction, rational_number = self.traverse_matrix(direction,
                                                        rational_number)
    end
  end

  def traverse_matrix(direction, current)
    if not is_in_direction(direction, current)
      new_element = change_direction(direction, current)
      direction = toggle_direction(direction)
    else
      new_element = move(direction, current)
    end
    new_rational = InternalRational.new(new_element[:numerator],
                                        new_element[:denominator])
    if new_rational.numerator.gcd(new_rational.denominator) != 1
      traverse_matrix(direction, new_rational)
    else
      [direction, new_rational]
    end
  end
end


class PrimeSequence
  include Enumerable
  include DrunkenMathematician

  def initialize(limit)
    @limit = limit
  end

  def each
    prime_number = 2
    current = 0
    while current < @limit
      yield prime_number
      current += 1
      prime_number = get_next_prime(prime_number)
    end
  end

  def get_next_prime(current_prime)
    next_prime = current_prime + 1
    while not prime?(next_prime)
      next_prime += 1
    end
    next_prime
  end
end


class FibonacciSequence
  include Enumerable

  def initialize(limit, first: 1, second: 1)
    @limit = limit
    @first = first
    @second = second
  end

  def each
    current = 0
    while current < @limit
      yield @first
      @first, @second, current = @second, @first + @second, current + 1
    end
  end
end