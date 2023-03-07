# frozen_string_literal: true

class Score
  attr_reader :scores

  def initialize(command_line_args)
    raise ArgumentError, '1-9の範囲の数字、またはX(ストライク)を渡して下さい' if unexpected_args?(command_line_args)

    divided_scores = divide_scores(command_line_args)
    processed_scores = process_score(divided_scores)
    @scores = processed_scores.flatten
  end

  def unexpected_args?(command_line_args)
    command_line_args.split(',').grep_v(/[0-9X]/).any?
  end

  def divide_scores(command_line_args)
    command_line_args.split(',')
  end

  def process_score(divided_scores)
    divided_scores.map do |score|
      score == 'X' ? %w[10 0] : score
    end
  end
end
