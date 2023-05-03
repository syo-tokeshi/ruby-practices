module Greet
  class << self
    def morning
      "class morning!!"
    end

    def hello
      "class hello!"
    end
  end

  def morning
    "instance morning!!"
  end
  def hello
    "instance hello!"
  end
end