#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'
require_relative 'detailed_file_manager'
require_relative 'file_manager'

class LsManager
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
    FileManager.new(files)
  end

  def output_detail(files)
    detailed_files = files.get_detailed_files(@path)
    total_blocks = files.get_total_blocks(detailed_files)
    puts "total #{total_blocks}"
    detailed_files.map do |detailed_file|
      types, permission, nlink, user, group, size, mtime, file_name = detailed_file[1..]
      puts [types, permission, nlink, user, group, size, mtime, file_name].join
    end
  end

  def output_without_detail(files)
    file_names = files.file_names
    aligned_file_names = files.align_file_names(file_names, added_space: 8, right_justified_flag: false)
    transposed_file_names = files.transpose_file_names(aligned_file_names)
    transposed_file_names.each do |columns|
      columns.each { |file_name| print file_name }
      print "\n"
    end
  end
end
