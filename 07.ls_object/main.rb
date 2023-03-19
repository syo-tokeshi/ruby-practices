#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'ls_manager'

OPTIONS = ARGV.getopts('a', 'r', 'l')

ls_manager = LsManager.new(OPTIONS, ARGV[0])
ls_manager.output
