#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'ls'

OPTIONS = ARGV.getopts('a', 'r', 'l')

ls = Ls.new(OPTIONS, ARGV[0])
ls.output
