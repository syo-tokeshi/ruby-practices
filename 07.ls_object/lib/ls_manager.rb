#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'
require_relative 'file_metadata'
require_relative 'files_formatter'

class LsManager
  def initialize(options, path = nil)
    @path = path
    @is_dotmatch = options['a']
    @is_reversed = options['r']
    @is_detailed = options['l']
  end

  def output
    files = files_by_option_and_path
    @is_detailed ? output_detail(files) : output_without_detail(files)
  end

  private

  def files_by_option_and_path
    dotmatch_pattern = @is_dotmatch ? File::FNM_DOTMATCH : 0
    files = if @path.nil?
              Dir.glob('*', dotmatch_pattern)
            elsif FileTest.directory? @path
              Dir.glob(File.join(@path, '*'), dotmatch_pattern)
            elsif FileTest.file? @path
              [@path]
            else
              raise ArgumentError "ls: #{ARGV[0]}: No such file or directory"
            end
    @is_reversed ? files.reverse! : files
    FilesFormatter.new(files)
  end

  def output_detail(files)
    detailed_files = files.get_detailed_files(@path)
    total_blocks = files.get_total_blocks(detailed_files)
    puts "total #{total_blocks}"
    detailed_files.map do |detailed_file|
      puts detailed_file[1..].join
    end
  end

  def output_without_detail(files)
    files.displayed_file_names.each do |columns|
      columns.each { |file_name| print file_name }
      print "\n"
    end
  end
end
