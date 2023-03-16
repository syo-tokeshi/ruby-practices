#!/usr/bin/env ruby
# frozen_string_literal: true
require 'optparse'
require_relative 'ls'
require 'debug'

OPTIONS = ARGV.getopts('a', 'r', 'l')

ls = Ls.new(ARGV[0], OPTIONS['a'], OPTIONS['r'], OPTIONS['l'])
ls.output

