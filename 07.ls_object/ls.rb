#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'
require 'debug'
require_relative 'file_information'

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
    file_informations = get_file_informations(file_names)
    total_blocks = get_total_blocks(file_informations)
    puts "total #{total_blocks}" if total_blocks > 1
    file_informations.map do |file_info|
      types, permissions, nlinks, users, groups, sizes, mtimes, file_names = file_info[1..]
      puts [types, permissions, nlinks, users, groups, sizes, mtimes, file_names].join
    end
  end

  def output_without_detail(files)
    file_names = get_file_names(files)
    aligned_file_names = align_files(file_names, 1, right_justified_flag: false)
    transposed_file_names = transpose_file_names(aligned_file_names)
    transposed_file_names.each do |columns|
      columns.each { |file_name| print file_name }
      print "\n"
    end
  end

  def align_files(file_informations, added_space = 1, right_justified_flag: true)
    word_counts = get_word_counts(file_informations)
    max_length = get_max_length(added_space, word_counts)
    file_informations.map do |file_info|
      if right_justified_flag
        file_info.rjust(max_length)
      else
        file_info.ljust(max_length)
      end
    end
  end

  def transpose_file_names(file_names, column_count = 3)
    row_count = get_row_count(column_count, file_names)
    sliced_file_names = slice_file_names(file_names, row_count)
    offset_for_transpose(row_count, sliced_file_names)
    sliced_file_names.transpose
  end

  def get_detailed_files(file_names)
    detailed_files = file_names.map { |file_name| FileInformation.new(File::Stat.new(file_name),file_name) }
    detailed_files.map { |file| file.informations}
  end

  def get_total_blocks(file_informations)
    file_informations.map { |file_info| file_info[0] }.sum
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

  def get_max_length(added_space, word_counts)
    word_counts.max + added_space
  end

  def get_word_counts(file_informations)
    file_informations.map { |file_info| file_info.size }
  end

  def get_file_names(files)
    files.map { |file| File.basename(file) }
  end

  def get_file_informations(file_names)
    get_detailed_files(file_names)
  end
end
