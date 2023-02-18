#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'debug'

PARAMS = ARGV.getopts('l', 'w', 'c')

def main
  if ARGV.any?
    info_to_display = file_count
    displayed_arg_info = calc_arg_info(info_to_display)
    displayed_wc(displayed_arg_info)
  else
    params = $stdin.readlines
    input_count(params)
  end
end

def displayed_wc(displayed_arg_info)
  displayed_count = PARAMS.values.count(true) + 1
  displayed_count = 4 if PARAMS.values.count(true) == 0
  displayed_arg_info.transpose.each do |rows|
    rows.each.with_index(1) do |row, i|
      print row.to_s.rjust(8.5) if i % displayed_count != 0
      print "#{row}\n" if i % displayed_count == 0
    end
  end
end

def calc_arg_info(info_to_display)
  sum_files = info_to_display.map(&:sum)
  displayed_arg_info = info_to_display.each_with_index { |row,i |
    row << sum_files[i]
  }
  # debugger
  last_columns = ARGV.map do
    " #{File.path(_1)}"
  end
  last_columns << " total"
  displayed_arg_info << last_columns
  # debugger
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
    files_lines
end

# 単語数
def count_words(files)
  files_words = files.map do
    _1.split(/\s+/).size
  end
    files_words
end

# 文字数
def count_characters(files)
  files_characters = files.map do
    _1.split(/\s+/).join.chars.size
    # debugger
  end
    files_characters
end

# 標準入力を調べる
def input_count(params)
  p params
end

main
