#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative '../lib/ls_manager'

options = ARGV.getopts('a', 'r', 'l')
path = ARGV[0]

ls_manager = LsManager.new(options, path)
ls_manager.exec
