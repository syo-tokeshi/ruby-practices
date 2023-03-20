# frozen_string_literal: true

require_relative 'detailed_file_manager'

class FileManager
  attr_reader :files

  def initialize(files)
    @files = files
  end

  def file_names
    files.map { |list| File.basename(list) }
  end

  def get_detailed_files(path)
    detailed_files = files.map do |list|
      create_detailed_files(list, path)
    end
    detailed_files.map(&:attributes)
  end

  def get_total_blocks(detailed_files)
    detailed_files.map { |detailed_file| detailed_file[0] }.sum
  end

  def align_file_names(file_names, added_space: 8, right_justified_flag: true)
    file_name_lengths = get_file_name_lengths(file_names)
    displayed_length = get_displayed_length(file_name_lengths, added_space)
    file_names.map do |file_name|
      if right_justified_flag
        file_name.rjust(displayed_length)
      else
        file_name.ljust(displayed_length)
      end
    end
  end

  def transpose_file_names(file_names, column_count = 3)
    row_count = get_row_count(column_count, file_names)
    sliced_file_names = slice_file_names(file_names, row_count)
    offset_for_transpose(row_count, sliced_file_names)
    sliced_file_names.transpose
  end

  private

  def create_detailed_files(file_name, path)
    if path.nil? || FileTest.file?(path)
      DetailedFileManager.new(File::Stat.new(file_name), file_name)
    elsif FileTest.directory? path
      displayed_file_name = file_name.delete(path)[1..]
      DetailedFileManager.new(File::Stat.new(file_name), displayed_file_name)
    end
  end

  def get_file_name_lengths(file_names)
    file_names.map(&:length)
  end

  def get_displayed_length(file_name_lengths, added_space)
    file_name_lengths.max + added_space
  end

  def get_row_count(column_count, file_names)
    file_names.length.quo(column_count).ceil
  end

  def slice_file_names(file_names, row_count)
    file_names.each_slice(row_count).to_a
  end

  def offset_for_transpose(row_count, sliced_file_names)
    (row_count - sliced_file_names[-1].length).times { sliced_file_names[-1] << '' }
  end
end
