# frozen_string_literal: true

class Frame
  attr_reader :shots

  def initialize(shots)
    @shots = shots
  end

  def sum_shots
    @shots.map(&:point).sum
  end
end
