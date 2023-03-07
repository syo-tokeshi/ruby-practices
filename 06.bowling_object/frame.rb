require_relative 'shot'
require 'debug'

class Frame
  attr_reader :shots
  def initialize(shots)
    @shots = shots
  end

  def sum_frame
    @shots.map do |s|
      s.mark
    end.sum
  end
end
