# frozen_string_literal: true

require_relative 'file_metadata'

class FilesFormatter
  def initialize(file_names)
    @file_names = file_names
  end

  def output_with_metadatas
    file_metadatas = create_file_metadatas
    total_blocks = file_metadatas.sum(&:blocks)
    puts "total #{total_blocks}"
    file_metadatas.each do |file|
      puts file.metadata
    end
  end

  def output_without_metadatas
    file_names_for_display.each do |columns|
      columns.each { |file_name| print file_name }
      print "\n"
    end
  end

  private

  def file_base_names
    @file_names.map { |file_name| File.basename(file_name) }
  end

  def create_file_metadatas
    @file_names.map do |file_name|
      FileMetadata.new(file_name)
    end
  end

  def file_names_for_display(column_count = 3)
    aligned_file_names = align_file_names
    row_count = get_row_count(column_count, aligned_file_names)
    sliced_file_names = slice_file_names(aligned_file_names, row_count)
    offset_for_transpose(row_count, sliced_file_names)
    sliced_file_names.transpose
  end

  def align_file_names(added_space: 8)
    displayed_length = get_displayed_length(added_space)
    file_base_names.map do |file_name|
      file_name.ljust(displayed_length)
    end
  end

  def get_displayed_length(added_space)
    file_name_lengths.max + added_space
  end

  def file_name_lengths
    file_base_names.map(&:length)
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
