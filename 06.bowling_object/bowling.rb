#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'
require_relative 'game'
require 'debug'

args = ARGV[0]

scores_before_processed = args.split(',')

scores_after_processed = scores_before_processed.map { |score|
  score == "X" ?  %w[10 0] : score
}

bowling_score = scores_after_processed.flatten

shots = bowling_score.map do |s|
  Shot.new(s)
end

frames = []
shots.each_slice(2) do |s|
  frames << Frame.new(s)
end

game = Game.new(frames)
p game.score
