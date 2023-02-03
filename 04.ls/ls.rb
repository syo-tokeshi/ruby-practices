#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'

files_in_current_path = Dir.glob('*')

# カレントディレクトリにあるファイルを全て受け取って、表示する列数で割って、1列辺りの数と余りを取得
def file_display_to_required_info(files_in_current_path)
  column_count_file_show = 3
  files_in_current_path.count.divmod(column_count_file_show)
end

number_column_show, remainder_number = file_display_to_required_info(files_in_current_path)

number_column_show += 1 if remainder_number.positive?

# 全部のファイル群を、1列辺りの平均値で、配列を作成
files_to_display = files_in_current_path.each_slice(number_column_show).to_a

file_and_file_between_space = 7

def max_filename_each_row(row)
  row.map(&:size).max
end

# 表示する列の最大幅を決める
displayed_file_array_max_name_number = files_to_display.map do |row|
  max_filename_each_row(row) + file_and_file_between_space
end

# グループ化したファイル群を、ljustで、左揃えさせる(その際に、そのグループのファイル名の最大文字数を考慮する)
adjusted_displayed_file = files_to_display.map.with_index do |row, index|
  row.map do |file_name|
    file_name.ljust(displayed_file_array_max_name_number[index])
  end
end

files_displayed_adjusted_by_index_number = adjusted_displayed_file[0].zip(*adjusted_displayed_file[1..])

files_displayed_adjusted_by_index_number.each do |column|
  column.count.times do |index|
    print column[index]
  end
  print "\n"
end
