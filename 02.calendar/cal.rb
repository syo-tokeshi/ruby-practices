# frozen_string_literal: true

require 'date'
require 'optparse'

params = ARGV.getopts('y:', 'm:')

year = (params['y'] || Date.today.year).to_i
month = (params['m'] || Date.today.month).to_i

start_day = Date.new(year, month, 1)
end_day = Date.new(year, month, -1)

calendar_of_first_weeks_spaces = '   ' * start_day.wday

def format_date(day_data)
  "#{day_data.day.to_s.rjust(2)} "
end

puts "#{month}月 #{year}".center(20)
puts '日 月 火 水 木 金 土'
print calendar_of_first_weeks_spaces

(start_day..end_day).each do |day_data|
  if day_data.wday == 6
    puts format_date(day_data)
  else
    print format_date(day_data)
  end
end
