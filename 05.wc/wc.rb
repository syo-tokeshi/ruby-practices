#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'debug'

WC_OPTIONS = ARGV.getopts('l', 'w', 'c')

def main
  if ARGV.any?
    loaded_files = load_file_data
    displayed_data = create_display_data(loaded_files)
    displayed_data_by_condition = if loaded_files.count >= 2
                           calculate_total_value(displayed_data)
                         else
                           file_name = File.path(ARGV[0])
                           displayed_data << [" #{file_name}"]
                         end
    display(displayed_data_by_condition)
  else
    params = $stdin.readlines
    input_count(params)
  end
end

def load_file_data
  ARGV.map do
    File.read(_1)
  end
end

# 引数で渡されたファイルを調べる
def create_display_data(loaded_files)
  display_data = []
  if !WC_OPTIONS.values.any?
    display_data.push(count_lines(loaded_files), count_words(loaded_files), count_characters(loaded_files))
  else
    display_data << count_lines(loaded_files) if WC_OPTIONS['l']
    display_data << count_words(loaded_files) if WC_OPTIONS['w']
    display_data << count_characters(loaded_files) if WC_OPTIONS['c']
  end
  display_data
end

# 標準入力を調べる
def input_count(params)
  divided_standard_input = params.map do
    [_1]
  end
  divided_standard_input
  info_to_display = []
  if !WC_OPTIONS.values.any?
    info_to_display << count_displayed_line(divided_standard_input)
    info_to_display << count_displayed_word(divided_standard_input)
    info_to_display << count_displayed_character(divided_standard_input)
  else
    info_to_display << count_displayed_line(divided_standard_input) if WC_OPTIONS['l']
    info_to_display << count_displayed_word(divided_standard_input) if WC_OPTIONS['w']
    info_to_display << count_displayed_character(divided_standard_input) if WC_OPTIONS['c']
  end
  displayed_standard_input(info_to_display)
end

def displayed_standard_input(info_to_display)
  info_to_display.each do |row|
      print row.to_s.rjust(8.5)
  end
end

def count_displayed_line(divided_standard_input)
  divided_standard_input.count
end

def count_displayed_word(divided_standard_input)
  word_counts = divided_standard_input.map do |line|
    line.join.scan(/\S+/).count
  end
  word_counts.sum
end

def count_displayed_character(divided_standard_input)
  divided_standard_input.flatten.join.size
end

def display(displayed_data)
  received_wc_option_count = WC_OPTIONS.values.count(true)
  column_count = received_wc_option_count == 0 ? 4 : received_wc_option_count + 1
  displayed_data.transpose.each do |rows|
    rows.each.with_index(1) do |row, index|
      print row.to_s.rjust(8.5) if index % column_count != 0
      print "#{row}\n" if index % column_count == 0
    end
  end
end

def calculate_total_value(displayed_data)
  sum_files = displayed_data.map(&:sum)
  displayed_arg_info = displayed_data.each_with_index { |row,i |
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

# 行数
def count_lines(files)
  new_lines = files.map do |file|
    # _1.lines.join.scan(/\n/).count
    file.lines.map do |line|
      line.scan(/\n$/)
    end
  end
  count_new_lines = new_lines.map do |line|
    line.flatten.count("\n")
  end
  count_new_lines
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
    # _1.split(/\s+/).join.chars.size
    _1.size
  end
    files_characters
end

main
