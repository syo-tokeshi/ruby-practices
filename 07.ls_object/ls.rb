#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'
require_relative 'detailed_file'

class Ls
  def initialize(options, path = nil)
    @path = path
    @is_dotmatch = options['a']
    @is_reversed = options['r']
    @is_detailed = options['l']
  end

  def output
    files = get_files_from_path(@path, @is_dotmatch)
    @is_detailed ? output_detail(files) : output_without_detail(files)
  end

  private

  def get_files_from_path(path, is_dotmatch)
    dotmatch_pattern = is_dotmatch ? File::FNM_DOTMATCH : 0
    files(path, dotmatch_pattern)
  end

  def files(path, dotmatch_pattern)
    files = if path.nil?
              Dir.glob('*', dotmatch_pattern)
            elsif FileTest.directory? path
              Dir.glob(File.join(path, '*'), dotmatch_pattern)
            elsif FileTest.file? path
              [path]
            else
              raise ArgumentError "ls: #{ARGV[0]}: No such file or directory"
            end
    @is_reversed ? files.reverse! : files
  end

  def output_detail(files)
    file_names = get_file_names(files)
    detailed_files = get_detailed_files(file_names)
    total_blocks = get_total_blocks(detailed_files)
    puts "total #{total_blocks}"
    detailed_files.map do |detailed_file|
      types, permission, nlink, user, group, size, mtime, file_name = detailed_file[1..]
      puts [types, permission, nlink, user, group, size, mtime, file_name].join
    end
  end

  def output_without_detail(files)
    file_names = get_file_names(files)
    aligned_file_names = align_file_names(file_names, 1, right_justified_flag: false)
    transposed_file_names = transpose_file_names(aligned_file_names)
    transposed_file_names.each do |columns|
      columns.each { |file_name| print file_name }
      print "\n"
    end
  end

  def align_file_names(file_names, added_space = 1, right_justified_flag: true)
    file_name_lengths = get_file_name_lengths(file_names)
    displayed_length = get_displayed_length(added_space, file_name_lengths)
    file_names.map do |file_name|
      if right_justified_flag
        file_name.rjust(displayed_length)
      else
        file_name.ljust(displayed_length)
      end
    end
  end

  def get_file_name_lengths(file_names)
    file_names.map(&:length)
  end

  def get_displayed_length(added_space, file_name_lengths)
    file_name_lengths.max + added_space
  end

  def transpose_file_names(file_names, column_count = 3)
    row_count = get_row_count(column_count, file_names)
    sliced_file_names = slice_file_names(file_names, row_count)
    offset_for_transpose(row_count, sliced_file_names)
    sliced_file_names.transpose
  end

  def get_detailed_files(file_names)
    detailed_files = file_names.map do |file_name|
      create_detailed_files(file_name)
    end
    detailed_files.map(&:informations)
  end

  def create_detailed_files(file_name)
    if @path.nil? || FileTest.file?(@path)
      DetailedFile.new(File::Stat.new(file_name), file_name)
    elsif FileTest.directory? @path
      DetailedFile.new(File::Stat.new("#{@path}/#{file_name}"), file_name)
    end
  end

  def get_total_blocks(detailed_files)
    detailed_files.map { |detailed_file| detailed_file[0] }.sum
  end

  def offset_for_transpose(row_count, sliced_file_names)
    (row_count - sliced_file_names[-1].length).times { sliced_file_names[-1] << '' }
  end

  def slice_file_names(file_names, row_count)
    file_names.each_slice(row_count).to_a
  end

  def get_row_count(column_count, file_names)
    file_names.length.quo(column_count).ceil
  end

  def get_file_names(files)
    files.map { |file| File.basename(file) }
  end
end
