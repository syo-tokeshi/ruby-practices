#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'
require_relative 'game'
require_relative 'frame'
require_relative 'shot'

shot = Shot.new('X')
p shot.mark
p shot.score

score = ARGV[0]

scores = score.split(',')
p scores
# shots = []
# scores.each do |s|
#   if s == 'X'
#     shots << 10
#     shots << 0
#   else
#     shots << s.to_i
#   end
# end
# frames = []
# shots.each_slice(2) do |s|
#   frames << s
# end
#
# total_point = 0
# frames.each.with_index(1) do |frame, index|
#   total_point += frame.sum
#   if frame[0] == 10 && index < 10 # ストライクの処理
#     total_point += if frames[index][0] == 10
#                      10 + frames[index + 1][0] # ダブルなので、2つ後の値も入れる
#                    else
#                      frames[index].sum
#                    end
#   elsif frame.sum == 10 && index < 10 # スペアの処理
#     total_point += frames[index][0]
#   end
# end
# p total_point