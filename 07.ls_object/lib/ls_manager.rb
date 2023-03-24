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
    formatted_files_from_now = parse_formatted_files(files)
    @is_detailed ? output_detail(formatted_files_from_now) : output_without_detail(formatted_files_from_now)
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
  end

  def parse_formatted_files(files)
    FilesFormatter.new(files)
  end

  def output_detail(files)
    files_with_metadatas = files.get_files_with_metadatas(@path)
    total_blocks = files.get_total_blocks(files_with_metadatas)
    puts "total #{total_blocks}"
    files_with_metadatas.each do |file_with_metadatas|
      puts file_with_metadatas[1..].join
    end
  end

  def output_without_detail(files)
    files.file_names_for_display.each do |columns|
      columns.each { |file_name| print file_name }
      print "\n"
    end
  end
end
