# crazy.rb - hw#1 solutions
# by comco

class Integer
  def prime_divisors
    a = []
    (2..abs).each { |e| a << e if (abs % e == 0) and a.all? { |f| e % f != 0 } }
    a
  end
end

class Range
  def fizzbuzz
    map do |e|
      x = :fizz if e % 3 == 0
      x = "#{x}buzz".to_sym if e % 5 == 0
      x ||= e
    end
  end
end

class Hash
  def group_values
    h = {}
    each { |k, v| (h[v] ||= []) << k }
    h
  end
end

class Array
  def densities
    map { |e| self.count e }
  end
end
