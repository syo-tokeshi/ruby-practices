# frozen_string_literal: true

module Growth
  def twice_increment(times = 1)
    @age = age * (2 * times)
  end

  def twice_decrement(times = 1)
    @age = age / (2 * times)
  end
end
