#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'debug'

WC_OPTIONS = ARGV.getopts('l', 'w', 'c')

def main
  if ARGV.any?
    loaded_files = ARGV.map do
      File.read(_1)
    end
    displayed_data = create_display_file_data(loaded_files)
    displayed_data_by_condition = if loaded_files.count >= 2
                           calculate_total_value(displayed_data)
                         else
                           file_name = File.path(ARGV[0])
                           displayed_data << [" #{file_name}"]
                         end
    display(displayed_data_by_condition)
  else
    stdin_data = $stdin.readlines
    divided_stdin_data = stdin_data.map do
      [_1]
    end
    displayed_data = create_display_stdin_data(divided_stdin_data)
    displayed_data.each do
      print _1.to_s.rjust(8.5)
    end
  end
end

def create_display_file_data(file)
  display_data = []
  if !WC_OPTIONS.values.any?
    display_data.push(count_file_lines(file), count_file_words(file), count_file_characters(file))
  else
    display_data << count_file_lines(file) if WC_OPTIONS['l']
    display_data << count_file_words(file) if WC_OPTIONS['w']
    display_data << count_file_characters(file) if WC_OPTIONS['c']
  end
  display_data
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
  column_total_count = displayed_data.map(&:sum)
  added_total_count_data = displayed_data.each_with_index { |column,index |
    column << column_total_count[index]
  }
  file_name = ARGV.map do
    " #{File.path(_1)}"
  end
  last_columns = file_name
  last_columns << " total"
  added_total_count_data << last_columns
end

def count_file_lines(files)
  new_lines = files.map do |file|
    file.lines.map do |line|
      line.scan(/\n$/)
    end
  end
  count_new_lines = new_lines.map do |line|
    line.flatten.count("\n")
  end
  count_new_lines
end

def count_file_words(files)
  files_words = files.map do
    _1.split(/\s+/).size
  end
  files_words
end

def count_file_characters(files)
  files_characters = files.map do
    _1.size
  end
  files_characters
end

def create_display_stdin_data(stdin_data)
  display_data = []
  if !WC_OPTIONS.values.any?
    display_data.push(count_stdin_line(stdin_data), count_stdin_word(stdin_data), count_stdin_character(stdin_data))
  else
    display_data << count_stdin_line(stdin_data) if WC_OPTIONS['l']
    display_data << count_stdin_word(stdin_data) if WC_OPTIONS['w']
    display_data << count_stdin_character(stdin_data) if WC_OPTIONS['c']
  end
end

def count_stdin_line(divided_standard_input)
  divided_standard_input.count
end

def count_stdin_word(divided_standard_input)
  word_counts = divided_standard_input.map do |line|
    line.join.scan(/\S+/).count
  end
  word_counts.sum
end

def count_stdin_character(divided_standard_input)
  divided_standard_input.flatten.join.size
end

main
