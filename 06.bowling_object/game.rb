# frozen_string_literal: true

require_relative 'argv_parser'
require_relative 'shot'
require_relative 'frame'

class Game
  def initialize(argv)
    argv = ArgvParser.new(argv)
    shots = argv.parsed_argv.map do |s|
      Shot.new(s)
    end
    @frames = shots.each_slice(2).map do |s|
      Frame.new(s)
    end
  end

  def calc_frames
    total_point = 0
    @frames.each.with_index(1) do |frame, index|
      total_point += frame.sum_shots
      if frame.shots[0].point == 10 && index < 10 # ストライクの処理
        total_point += calc_strike_except_last_frame(index)
      elsif frame.sum_shots == 10 && index < 10 # スペアの処理
        total_point += calc_spare_except_last_frame(index)
      end
    end
    total_point
  end

  private

  def calc_spare_except_last_frame(index)
    @frames[index].shots[0].point
  end

  def calc_strike_except_last_frame(index)
    if @frames[index].shots[0].point == 10
      10 + @frames[index + 1].shots[0].point # ダブルなので、2つ後の値も入れる
    else
      @frames[index].sum_shots
    end
  end
end
