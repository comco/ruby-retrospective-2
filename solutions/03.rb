class Expr
  @@types = {}

  def ==(other)
    other.class == self.class and other.state == state
  end

  def self.build(s_expr)
    type, *s_args = *s_expr
    @@types[type].build(s_args)
  end

  def +(other)
    Addition.new(self, other)
  end

  def *(other)
    Multiplication.new(self, other)
  end

  def -@
    Negation.new(self)
  end

  def simplify
    self
  end
end

class Atomic < Expr
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def self.build(value)
    new value.first
  end

  alias state value
end

class Number < Atomic
  @@types[:number] = self

  ZERO = self.new(0)
  ONE = self.new(1)

  def evaluate(environment = {})
    value
  end

  def derive(variable)
    ZERO
  end

  def exact?
    true
  end
end

class Variable < Atomic
  @@types[:variable] = self

  def evaluate(environment = {})
    if environment.has_key? value
      environment[value]
    else
      raise 'Uninitialized variable during evaluation.'
    end
  end

  def derive(variable)
    if value == variable
      Number::ONE
    else
      Number::ZERO
    end
  end

  def exact?
    false
  end
end

class Composite < Expr
  attr_accessor :args

  def initialize(*args)
    @args = args
  end

  def self.build(s_args)
    new(*s_args.map { |s_expr| Expr.build(s_expr) })
  end

  alias state args

  def evaluate(environment = {})
    self.class.compute_value(*args.map { |expr| expr.evaluate(environment) })
  end

  def derive(variable)
    arg_derives = args.map { |expr| expr.derive(variable) }
    self.class.compute_derivative(*args, *arg_derives).simplify
  end

  def exact?
    args.all? { |expr| expr.exact? }
  end

  def self.simplify_step(whole, *_)
    whole
  end

  def simplify
    if exact?
      Number.new(evaluate)
    else
      simple_args = args.map { |expr| expr.simplify }
      whole = self.class.new(*simple_args)
      self.class.simplify_step(whole, *simple_args)
    end
  end
end

class Addition < Composite
  @@types[:+] = self

  def self.compute_value(a, b)
    a + b
  end

  def self.compute_derivative(f, g, df, dg)
    df + dg
  end

  def self.simplify_step(whole, a, b)
    if a == Number::ZERO
      b
    elsif b == Number::ZERO
      a
    else
      whole
    end
  end
end

class Multiplication < Composite
  @@types[:*] = self

  def self.compute_value(a, b)
    a * b
  end

  def self.compute_derivative(f, g, df, dg)
    df * g + f * dg
  end

  def self.simplify_step(whole, a, b)
    if a == Number::ZERO or b == Number::ZERO
      Number::ZERO
    elsif a == Number::ONE
      b
    elsif b == Number::ONE
      a
    else
      whole
    end
  end
end

class Negation < Composite
  @@types[:-] = self

  def self.compute_value(a)
    -a
  end

  def self.compute_derivative(f, df)
    -df
  end

  def self.simplify_step(whole, a)
    if Negation == a.class
      a.args.first
    else
      whole
    end
  end
end

class Sine < Composite
  @@types[:sin] = self

  def self.compute_value(a)
    Math.sin(a)
  end

  def self.compute_derivative(f, df)
    df * Cosine.new(f)
  end
end

class Cosine < Composite
  @@types[:cos] = self

  def self.compute_value(a)
    Math.cos(a)
  end

  def self.compute_derivative(f, df)
    df * -Sine.new(f)
  end
end
