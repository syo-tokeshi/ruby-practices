#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require "etc"

TABLE_NUMERIC_ALPHABET = {
  '0' => '-',
  '1' => 'x--',
  '2' => 'w--',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

TABLE_FILETYPE_ALPHABET = {
  '100' => '-',
  '40' => 'd',
}.freeze

def make_authority_alphabetic(permissions)
  permissions.map{ |permission|
    TABLE_NUMERIC_ALPHABET[permission]
  }
end

def change_number_to_file_type(file_type)
  TABLE_FILETYPE_ALPHABET[file_type]
end

def get_array_of_file_type_and_permissions(string_of_file_type_and_permissions)
  user = string_of_file_type_and_permissions.slice!(-1)
  group = string_of_file_type_and_permissions.slice!(-1)
  owner = string_of_file_type_and_permissions.slice!(-1)
  file_type = string_of_file_type_and_permissions
  [owner,group,user,file_type]
end

params = ARGV.getopts('r')
files_in_current_path = if params['r']
                          Dir.glob('*').reverse
                        else
                          Dir.glob('*')
                        end

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
