#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'

def main
  if ARGV.any?
    file_count
  else
    params = $stdin.readlines
    input_count(params)
  end
end

# 引数で渡されたファイルを調べる
def file_count
  loaded_files = ARGV.map do
    File.read(_1)
  end
  count_lines(loaded_files)
  count_words(loaded_files)
  count_characters(loaded_files)
end

# 行数
def count_lines(files)
  files_lines = files.map do
    _1.lines.count
  end
  p files_lines
end

# 単語数
def count_words(files)
  files_words = files.map do
    _1.split(/\s+/).size
  end
  p files_words
end

# 文字数
def count_characters(files)
  files_characters = files.map do
    _1.split(/\s+/).join.chars.size
  end
  p files_characters
end

# 標準入力を調べる
def input_count(params)
  p params
end

main
