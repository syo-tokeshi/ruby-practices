#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'

def main
  if ARGV.any?
    file_count
  else
    params = $stdin.readlines
    input_count(params)
  end
end

def file_count
  p ARGV
end

def input_count(params)
  p params
end

main
