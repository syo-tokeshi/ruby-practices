# frozen_string_literal: true

require_relative 'file_metadata'

class FilesFormatter
  attr_reader :files

  def initialize(files)
    @files = files
  end

  def output_with_metadatas(path)
    files_with_metadatas = get_files_with_metadatas(path)
    total_blocks = get_total_blocks(files_with_metadatas)
    puts "total #{total_blocks}"
    files_with_metadatas.each do |file_with_metadatas|
      puts file_with_metadatas[1..].join
    end
  end

  def output_without_metadatas
    file_names_for_display.each do |columns|
      columns.each { |file_name| print file_name }
      print "\n"
    end
  end

  private

  def file_names
    @files.map { |list| File.basename(list) }
  end

  def get_files_with_metadatas(path)
    files_with_metadata = @files.map do |file|
      parse_file_with_metadatas(file, path)
    end
    files_with_metadata.map(&:metadatas)
  end

  def parse_file_with_metadatas(file_name, path)
    if path.nil? || FileTest.file?(path)
      FileMetadata.new(file_name)
    elsif FileTest.directory? path
      file_name_when_directory = file_name.delete(path)[1..]
      FileMetadata.new(file_name, file_name_when_directory)
    end
  end

  def get_total_blocks(files_with_metadata)
    files_with_metadata.sum { |detailed_file| detailed_file[0] }
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
    file_names.map do |file_name|
      file_name.ljust(displayed_length)
    end
  end

  def get_displayed_length(added_space)
    file_name_lengths.max + added_space
  end

  def file_name_lengths
    file_names.map(&:length)
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
