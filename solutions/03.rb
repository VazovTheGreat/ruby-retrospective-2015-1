class InternalRational
  attr_accessor :numerator
  attr_accessor :denominator

  def initialize(numerator, denominator)
    @numerator = numerator
    @denominator = denominator
  end
end

module DrunkenMathematician
  def is_prime(number)
    return false if number == 1

    max_possible = Math.sqrt(number).floor
    (2..max_possible).each { |x|
      return false if number % x == 0
    }
    true
  end

  def meaningless(seq_length)
    rational_numbers = RationalSequence.new(seq_length).to_a
    group1, group2 = [], []
    rational_numbers.each { |x|
      if is_prime(x.numerator) or is_prime(x.denominator)
        group1.push(x)
      else
        group2.push(x)
      end
    }
    product1, product2 = group1.reduce(:*) || 1, group2.reduce(:*) || 1
    Rational(product1, product2)
  end

  def aimless(seq_length)
    prime_numbers = PrimeSequence.new(seq_length).to_a
    rational_numbers = []
    prime_numbers.each_slice(2) { |x|
      rational_numbers.push(Rational *x)
    }
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

  module_function :is_prime
  module_function :meaningless
  module_function :aimless
  module_function :worthless

end

class RationalSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
    @up_direction   = lambda { |x|  { :numerator   => x.numerator - 1,
                                      :denominator => x.denominator + 1 }}
    @down_direction = lambda { |x| {:numerator   => x.numerator + 1,
                                    :denominator => x.denominator - 1 }}
    @change_direction_down = lambda { |x| { :numerator => x.numerator + 1,
                                            :denominator => x.denominator}}
    @change_direction_up   = lambda { |x| { :numerator => x.numerator,
                                            :denominator => x.denominator + 1}}
    @is_up_direction   = lambda { |x|  x.numerator - 1 > 0 }
    @is_down_direction = lambda { |x|  x.denominator - 1 > 0 }
    @movement_stack = { :up   => {:move => @up_direction, :change => @change_direction_up,
                                  :move? => @is_up_direction},:down => {:move => @down_direction,
                                                                        :change=> @change_direction_down, :move? => @is_down_direction}}
  end

  def each
    rational_number = InternalRational.new(1,1)
    current, direction =0, :down
    while current < @limit
      yield Rational(rational_number.numerator, rational_number.denominator)
      current += 1
      direction,rational_number = self.traverse_matrix(direction, rational_number)
    end
  end

  def traverse_matrix(direction, current)
    if not @movement_stack[direction][:move?]. (current)
      new_element = @movement_stack[direction][:change].call(current)
      direction = toggle_direction(direction)
    else
      new_element =@movement_stack[direction][:move].call(current)
    end
    new_rational = InternalRational.new(new_element[:numerator], new_element[:denominator])
    if new_rational.numerator.gcd(new_rational.denominator) != 1
      traverse_matrix(direction, new_rational)
    else
      [direction, new_rational]
    end
  end

  def toggle_direction (direction)
    if direction == :up
      :down
    else
      :up
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
    while not is_prime(next_prime)
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