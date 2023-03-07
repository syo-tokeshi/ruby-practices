# frozen_string_literal: true

class Game
  attr_reader :frames

  def initialize(frames)
    @frames = frames
  end

  def score
    total_point = 0
    @frames.each.with_index(1) do |frame, index|
      total_point += frame.sum_frame
      if frame.shots[0].mark == 10 && index < 10 # ストライクの処理
        total_point += process_in_strike(index)
      elsif frame.sum_frame == 10 && index < 10 # スペアの処理
        total_point += process_in_spare(index)
      end
    end
    total_point
  end

  def process_in_strike(index)
    if @frames[index].shots[0].mark == 10
      10 + @frames[index + 1].shots[0].mark # ダブルなので、2つ後の値も入れる
    else
      @frames[index].sum_frame
    end
  end

  def process_in_spare(index)
    @frames[index].shots[0].mark
  end
end
