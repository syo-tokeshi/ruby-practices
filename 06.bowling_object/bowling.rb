#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'argv_parser'
require_relative 'shot'
require_relative 'frame'
require_relative 'game'

argv = ArgvParser.new(ARGV[0])

shots = argv.parsed_argv.map do |s|
  Shot.new(s)
end

frames = shots.each_slice(2).map do |s|
  Frame.new(s)
end

game = Game.new(frames)
p game.calculate_frames
