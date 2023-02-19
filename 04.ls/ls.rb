#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

PERMISSION_TABLE = {
  '0' => '---',
  '1' => 'x--',
  '2' => 'w--',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

TYPE_TABLE = {
  '100' => '-',
  '40' => 'd',
  '120' => 'l'
}.freeze

COLUMN_COUNT = 3
COLUMN_SPACE = 7
PARAMS = ARGV.getopts('a', 'r', 'l')

def main(displayed_lists)
  current_path_lists, displayed_lists = *displayed_lists
  default_lists = displayed_lists[0].zip(*displayed_lists[1..])
  max_byte_count, sum_blocks_count = get_details_path_size(current_path_lists)
  if PARAMS['l']
    puts "total #{sum_blocks_count}" if current_path_lists.count >= 2
    display_with_detail(displayed_lists, max_byte_count)
  else
    display_without_detail(default_lists)
  end
end

def displayed_lists
  path_lists = change_state_lists
  display_column_count, remainder_count = path_lists.count.divmod(COLUMN_COUNT)
  display_column_count += 1 if remainder_count.positive?
  display_files = path_lists.each_slice(display_column_count).to_a
  display_widths = display_files.map do |row|
    row.map(&:size).max + COLUMN_SPACE
  end
  adjusted_displayed_lists = display_files.map.with_index do |row, index|
    row.map do |file_name|
      file_name.ljust(display_widths[index])
    end
  end
  [path_lists, adjusted_displayed_lists]
end

def change_state_lists
  flags = PARAMS['a'] ? File::FNM_DOTMATCH : 0
  path_lists = Dir.glob('*', flags)
  path_lists.reverse! if PARAMS['r']
  path_lists
end

def display_without_detail(lists)
  lists.each do |columns|
    columns.each do |column|
      print column
    end
    print "\n"
  end
end

def display_with_detail(lists, max_byte_count)
  lists.each do |columns|
    columns.each do |column|
      next if column.nil?

      removed_space_column = column.strip
      if FileTest.symlink?(removed_space_column)
        symbolic_name = "#{removed_space_column} -> #{File.readlink(removed_space_column)}"
        puts "#{display_file_type_and_permissions(removed_space_column)} #{display_remaining_details(removed_space_column, max_byte_count)} #{symbolic_name}"
      else
        puts "#{display_file_type_and_permissions(removed_space_column)} #{display_remaining_details(removed_space_column, max_byte_count)} #{removed_space_column}"
      end
    end
  end
end

def convert_alphabetic_permissions(numeric_permissions)
  numeric_permissions.map do
    PERMISSION_TABLE[_1]
  end
end

def convert_alphabetic_list_type(numeric_file_type)
  TYPE_TABLE[numeric_file_type]
end

def divide(file_mode)
  user = file_mode.slice!(-1)
  group = file_mode.slice!(-1)
  owner = file_mode.slice!(-1)
  file_type = file_mode
  [owner, group, user, file_type]
end

def display_file_type_and_permissions(file)
  has_detail_file = File::Stat.new(File.open(file))
  file_mode = has_detail_file.mode.to_s(8)
  type_and_permissions = divide(file_mode)
  list_type = convert_alphabetic_list_type(type_and_permissions.last)
  permissions = convert_alphabetic_permissions(type_and_permissions[0..2])
  list_type = 'l' if FileTest.symlink?(file)
  [list_type, permissions].flatten.join
end

def get_details_path_size(path_lists)
  lists_detail = path_lists.map do
    File::Stat.new(File.open(_1))
  end
  max_byte_count = lists_detail.map(&:size).map(&:to_s).map(&:size).max
  sum_blocks_count = lists_detail.map(&:blocks).sum
  [max_byte_count, sum_blocks_count]
end

def display_remaining_details(file, max_byte_count)
  has_detail_file = File::Stat.new(File.open(file))
  hard_link_count = has_detail_file.nlink
  owner_name = Etc.getpwuid(has_detail_file.uid).name
  group_name = Etc.getgrgid(has_detail_file.gid).name
  bite_size = has_detail_file.size.to_s.rjust(max_byte_count)
  updated_date = has_detail_file.mtime.strftime('%_m %_d %H:%M')
  [hard_link_count, owner_name, group_name, bite_size, updated_date].flatten.join('  ')
end

main(displayed_lists)
