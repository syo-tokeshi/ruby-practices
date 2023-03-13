# frozen_string_literal: true

class ArgvParser
  attr_reader :parsed_argv

  def initialize(command_line_argv)
    raise ArgumentError, '1-9の範囲の数字、またはX(ストライク)を渡して下さい' if unexpected_args?(command_line_argv)

    divided_argv = divide_argv(command_line_argv)
    @parsed_argv = parse_argv(divided_argv)
  end

  private

  def parse_argv(divided_argv)
    divided_argv.map do |argv|
      argv == 'X' ? %w[10 0] : argv
    end.flatten
  end

  def divide_argv(command_line_argv)
    command_line_argv.split(',')
  end

  def unexpected_args?(command_line_argv)
    command_line_argv.split(',').grep_v(/[0-9X]/).any?
  end
end
