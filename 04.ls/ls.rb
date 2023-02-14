#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

TABLE_NUMERIC_ALPHABET = {
  '0' => '---',
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

COLUMN_COUNT_FILE_SHOW = 3
FILE_AND_FILE_BETWEEN_SPACE = 7
PARAMS = ARGV.getopts('r', 'l')

def main(displayed_files)
  files_in_current_path, adjusted_displayed_files = *displayed_files
  adjusted_displayed_files_by_index_number = adjusted_displayed_files[0].zip(*adjusted_displayed_files[1..])
  max_byte_count_display_path, sum_blocks_count_display_path = display_path_size_detail(files_in_current_path)
  # debugger
  if PARAMS['l']
    puts "total #{sum_blocks_count_display_path}" if files_in_current_path.count >= 2
    path_detail_also_display(adjusted_displayed_files, max_byte_count_display_path)
  else
    display_without_option(adjusted_displayed_files_by_index_number)
  end
end

def displayed_files
  files_in_current_path = PARAMS['r'] ? Dir.glob('*').reverse : Dir.glob('*')
  number_column_show, remainder_number = files_in_current_path.count.divmod(COLUMN_COUNT_FILE_SHOW)
  number_column_show += 1 if remainder_number.positive?
  files_to_display = files_in_current_path.each_slice(number_column_show).to_a
  displayed_file_max_name_numbers = files_to_display.map do |row|
    row.map(&:size).max + FILE_AND_FILE_BETWEEN_SPACE
  end
  adjusted_displayed_files = files_to_display.map.with_index do |row, index|
    row.map do |file_name|
      file_name.ljust(displayed_file_max_name_numbers[index])
    end
  end
  [files_in_current_path, adjusted_displayed_files]
end

def display_without_option(adjusted_displayed_files_by_index_number)
  adjusted_displayed_files_by_index_number.each do |columns|
    columns.each do |column|
      print column
    end
    print "\n"
  end
end

def path_detail_also_display(adjusted_displayed_files, max_byte_count_display_path)
  adjusted_displayed_files.each do |columns|
    columns.each do |column|
      next if column.nil?

      removed_space_column = column.strip
      if FileTest.symlink?(removed_space_column)
        symbolic_name_to_display = "#{removed_space_column} -> #{File.readlink(removed_space_column)}"
        puts "#{display_file_type_and_permission(removed_space_column)} #{show_remaining_detail(removed_space_column,
                                                                                                max_byte_count_display_path)} #{symbolic_name_to_display}"
      else
        puts "#{display_file_type_and_permission(removed_space_column)} #{show_remaining_detail(removed_space_column,
                                                                                                max_byte_count_display_path)} #{removed_space_column}"
      end
    end
  end
end

def make_authority_alphabetic(permissions)
  permissions.map do |permission|
    TABLE_NUMERIC_ALPHABET[permission]
  end
end

def change_number_to_file_type(file_type)
  TABLE_FILETYPE_ALPHABET[file_type]
end

def get_file_type_and_permissions(string_of_file_type_and_permissions)
  user = string_of_file_type_and_permissions.slice!(-1)
  group = string_of_file_type_and_permissions.slice!(-1)
  owner = string_of_file_type_and_permissions.slice!(-1)
  file_type = string_of_file_type_and_permissions
  [owner, group, user, file_type]
end

def display_file_type_and_permission(file)
  file_hold_detail = File::Stat.new(File.open(file))
  string_of_file_type_and_permissions = file_hold_detail.mode.to_s(8)
  array_of_file_type_and_permissions = get_file_type_and_permissions(string_of_file_type_and_permissions)
  file_type = change_number_to_file_type(array_of_file_type_and_permissions.last)
  permissions = make_authority_alphabetic(array_of_file_type_and_permissions[0..2])
  file_type = 'l' if FileTest.symlink?(file)
  [file_type, permissions].flatten.join
end

def display_path_size_detail(files_in_current_path)
  files_with_detail_information = files_in_current_path.map do |file|
    File::Stat.new(File.open(file))
  end
  max_byte_count_display_path = files_with_detail_information.map(&:size).map(&:to_s).map(&:size).max
  sum_blocks_count_display_path = files_with_detail_information.map(&:blocks).sum
  [max_byte_count_display_path, sum_blocks_count_display_path]
end

def show_remaining_detail(file, max_byte_count_display_path)
  file_hold_detail = File::Stat.new(File.open(file))
  hard_link_count = file_hold_detail.nlink
  owner_name = Etc.getpwuid(file_hold_detail.uid).name
  group_name = Etc.getgrgid(file_hold_detail.gid).name
  bite_size = file_hold_detail.size.to_s.rjust(max_byte_count_display_path)
  updated_date = file_hold_detail.mtime.strftime('%_m %_d %H:%M')
  [hard_link_count, owner_name, group_name, bite_size, updated_date].flatten.join('  ')
end

main(displayed_files)
