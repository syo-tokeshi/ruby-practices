# frozen_string_literal: true

require_relative 'human'
require_relative 'greet'
require_relative 'growth'

class Children < Human
  include Greet
  include Growth
  def greet
    "my name is #{name}, age is #{age} !!"
  end

  def adult?
    if age > 20
      'he is adult'
    elsif age <= 19 && age >= 6
      'he is children'
    else
      'he is piyopiyo'
    end
  end
end
