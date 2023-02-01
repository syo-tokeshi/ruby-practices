# frozen_string_literal: true

require 'date'
require 'optparse'

params = ARGV.getopts('y:', 'm:')

year = (params['y'] || Date.today.year).to_i
month = (params['m'] || Date.today.month).to_i

start_date = Date.new(year, month, 1)
end_date = Date.new(year, month, -1)

calendar_of_first_weeks_spaces = '   ' * start_date.wday

puts "#{month}月 #{year}".center(20)
puts '日 月 火 水 木 金 土'
print calendar_of_first_weeks_spaces

(start_date..end_date).each do |date|
  formatted_day = "#{date.day.to_s.rjust(2)} "
  if date.wday == 6
    puts formatted_day
  else
    print formatted_day
  end
end
