#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'file_metadata'
require_relative 'files_formatter'

class LsManager
  def initialize(options, path = nil)
    @path = path
    @is_dotmatch = options['a']
    @is_reversed = options['r']
    @is_detailed = options['l']
  end

  def exec
    file_names = files_by_option_and_path
    files_formatter = FilesFormatter.new(file_names)
    @is_detailed ? files_formatter.output_with_metadatas : files_formatter.output_without_metadatas
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
end
