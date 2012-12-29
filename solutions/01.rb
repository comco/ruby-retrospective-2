# crazy.rb - hw#1 solutions
# by comco

class Integer
  def prime_divisors
    2.upto(abs).select { |n| divisible_by?(n) && n.prime? }
  end

  def prime?
    not 2.upto(pred).any? { |n| divisible_by?(n) }
  end

  def divisible_by?(n)
    remainder(n).zero?
  end
end

class Range
  def fizzbuzz
    map do |n|
      if    n % 15 == 0 then :fizzbuzz
      elsif n % 3  == 0 then :fizz
      elsif n % 5  == 0 then :buzz
      else  n
      end
    end
  end
end

class Hash
  def group_values
    keys.group_by { |key| self[key] }
  end
end

class Array
  def densities
    map { |item| count item }
  end
end

