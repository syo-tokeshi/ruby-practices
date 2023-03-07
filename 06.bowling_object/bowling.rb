#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'
require_relative 'game'

scores = ARGV[0]
divided_scores = scores.split(',')

processed_scores = divided_scores.map do |score|
  score == 'X' ? %w[10 0] : score
end

processed_flat_score = processed_scores.flatten

shots = processed_flat_score.map do |s|
  Shot.new(s)
end

frames = shots.each_slice(2).map do |s|
  Frame.new(s)
end

game = Game.new(frames)
p game.calculate_frames
