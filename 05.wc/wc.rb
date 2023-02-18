#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'debug'

PARAMS = ARGV.getopts('l', 'w', 'c')

def main
  if ARGV.any?
    info_to_display = file_count
    calc_arg_info(info_to_display)
  else
    params = $stdin.readlines
    input_count(params)
  end
end

def calc_arg_info(info_to_display)
  sum_files = info_to_display.map(&:sum)
  displayed_arg_info = info_to_display.each_with_index { |row,i |
    row << sum_files[i]
  }
  p displayed_arg_info
end

# 引数で渡されたファイルを調べる
def file_count
  loaded_files = ARGV.map do
    File.read(_1)
  end
  info_to_display = []
  if !PARAMS.values.any?
    info_to_display << count_lines(loaded_files)
    info_to_display << count_words(loaded_files)
    info_to_display << count_characters(loaded_files)
  else
    info_to_display << count_lines(loaded_files) if PARAMS['l']
    info_to_display << count_words(loaded_files) if PARAMS['w']
    info_to_display << count_characters(loaded_files) if PARAMS['c']
  end
  info_to_display
end

# 行数
def count_lines(files)
  files_lines = files.map do
    _1.lines.count
  end
  p files_lines
end

# 単語数
def count_words(files)
  files_words = files.map do
    _1.split(/\s+/).size
  end
  p files_words
end

# 文字数
def count_characters(files)
  files_characters = files.map do
    _1.split(/\s+/).join.chars.size
  end
  p files_characters
end

# 標準入力を調べる
def input_count(params)
  p params
end

main
