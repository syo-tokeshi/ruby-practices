#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

params = ARGV.getopts('a')
files_in_current_path = params['a'] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')

COLUMN_COUNT_FILE_SHOW = 3
def file_display_to_required_info(files_in_current_path)
  files_in_current_path.count.divmod(COLUMN_COUNT_FILE_SHOW)
end

number_column_show, remainder_number = file_display_to_required_info(files_in_current_path)

number_column_show += 1 if remainder_number.positive?

files_to_display = files_in_current_path.each_slice(number_column_show).to_a

file_and_file_between_space = 7

def row_filename_max_length(row)
  row.map(&:size).max
end

displayed_file_max_name_numbers = files_to_display.map do |row|
  row_filename_max_length(row) + file_and_file_between_space
end

adjusted_displayed_files = files_to_display.map.with_index do |row, index|
  row.map do |file_name|
    file_name.ljust(displayed_file_max_name_numbers[index])
  end
end

adjusted_displayed_files_by_index_number = adjusted_displayed_files[0].zip(*adjusted_displayed_files[1..])

adjusted_displayed_files_by_index_number.each do |columns|
  columns.each do |column|
    print column
  end
  print "\n"
end
