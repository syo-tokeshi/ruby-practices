#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require "etc"
require "debug"

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
  '120' => 'l'
}.freeze

def make_authority_alphabetic(permissions)
  permissions.map{ |permission|
    TABLE_NUMERIC_ALPHABET[permission]
  }
end

def change_number_to_file_type(file_type)
  TABLE_FILETYPE_ALPHABET[file_type]
end

def get_file_type_and_permissions(string_of_file_type_and_permissions)
  user = string_of_file_type_and_permissions.slice!(-1)
  group = string_of_file_type_and_permissions.slice!(-1)
  owner = string_of_file_type_and_permissions.slice!(-1)
  file_type = string_of_file_type_and_permissions
  [owner,group,user,file_type]
end

params = ARGV.getopts('r', 'l')
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

def display_file_type_and_permission(file)
  file_hold_detail = File::Stat.new(File.open(file))
  string_of_file_type_and_permissions =  file_hold_detail.mode.to_s(8)
  array_of_file_type_and_permissions = get_file_type_and_permissions(string_of_file_type_and_permissions)
  file_type = change_number_to_file_type(array_of_file_type_and_permissions.last)
  permissions = make_authority_alphabetic(array_of_file_type_and_permissions[0..2])
  if FileTest.symlink?(file)
    file_type = "l"
  end
  [file_type,permissions].flatten.join
end

def get_max_byte_count_display_path(files_in_current_path)
  files_max_byte_number = files_in_current_path.map do |file|
    File::Stat.new(File.open(file)).size.to_s
  end
  files_max_byte_number.map(&:size).max
end

def show_remaining_detail(file,max_byte_count_display_path)
  file_hold_detail = File::Stat.new(File.open(file))
  hard_link_count = file_hold_detail.nlink
  owner_name = Etc.getpwuid(file_hold_detail.uid).name
  group_name = Etc.getgrgid(file_hold_detail.gid).name
  bite_size = file_hold_detail.size.to_s.rjust(max_byte_count_display_path)
  updated_date = file_hold_detail.mtime.strftime('%_m月 %_d %H:%M')
  [hard_link_count,owner_name,group_name,bite_size,updated_date].flatten.join("  ")
end

max_byte_count_display_path = get_max_byte_count_display_path(files_in_current_path)

if params['l']
  adjusted_displayed_files.each do |columns|
    columns.each do |column|
      if column
        removed_space_column = column.strip
        # debugger
        if FileTest.symlink?(removed_space_column)
          symbolic_name_to_display = "#{removed_space_column} -> #{File.readlink(removed_space_column)}"
          puts "#{display_file_type_and_permission(removed_space_column)} #{show_remaining_detail(removed_space_column,max_byte_count_display_path)} #{symbolic_name_to_display}"
        else
          puts "#{display_file_type_and_permission(removed_space_column)} #{show_remaining_detail(removed_space_column,max_byte_count_display_path)} #{removed_space_column}"
        end
      end
    end
  end
else
  adjusted_displayed_files_by_index_number.each do |columns|
    columns.each do |column|
      print column
    end
    print "\n"
  end
end
