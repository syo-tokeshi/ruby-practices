# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :shots

  def initialize(shots)
    @shots = shots
  end

  def sum_frame
    @shots.map(&:mark).sum
  end
end
