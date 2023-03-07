class Shot
  attr_reader :mark
  def initialize(mark)
    @mark = mark.to_i
  end
end
