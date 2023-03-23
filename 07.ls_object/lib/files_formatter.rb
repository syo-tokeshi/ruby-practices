# frozen_string_literal: true

require_relative 'file_metadata'

class FilesFormatter
  attr_reader :files

  def initialize(files)
    @files = files
  end

  def file_names
    @files.map { |list| File.basename(list) }
  end

  def get_detailed_files(path)
    detailed_files = @files.map do |list|
      create_detailed_files(list, path)
    end
    detailed_files.map(&:attributes)
  end

  def get_total_blocks(detailed_files)
    detailed_files.map { |detailed_file| detailed_file[0] }.sum
  end

  def align_file_names(added_space: 8)
    displayed_length = get_displayed_length(added_space)
    file_names.map do |file_name|
      file_name.ljust(displayed_length)
    end
  end

  def displayed_file_names(column_count = 3)
    aligned_file_names = align_file_names
    row_count = get_row_count(column_count, aligned_file_names)
    sliced_file_names = slice_file_names(aligned_file_names, row_count)
    offset_for_transpose(row_count, sliced_file_names)
    sliced_file_names.transpose
  end

  private

  def create_detailed_files(file_name, path)
    if path.nil? || FileTest.file?(path)
      FileMetadata.new(File::Stat.new(file_name), file_name)
    elsif FileTest.directory? path
      displayed_file_name = file_name.delete(path)[1..]
      FileMetadata.new(File::Stat.new(file_name), displayed_file_name)
    end
  end

  def file_name_lengths
    file_names.map(&:length)
  end

  def get_displayed_length(added_space)
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
