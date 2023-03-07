#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'score'
require_relative 'shot'
require_relative 'frame'
require_relative 'game'

score = Score.new(ARGV[0])

shots = score.scores.map do |s|
  Shot.new(s)
end

frames = shots.each_slice(2).map do |s|
  Frame.new(s)
end

game = Game.new(frames)
p game.calculate_frames
