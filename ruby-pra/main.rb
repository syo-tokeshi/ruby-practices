# frozen_string_literal: true

require_relative 'children'

toshi = Children.new('toshi', 19)
p toshi.age
p toshi.adult?
toshi.twice_increment(2)
p toshi.age
p toshi.adult?
toshi.twice_decrement
p toshi.age
# toshi.twice_decrement
# toshi.twice_decrement # ２倍する処理を引数で複数回出来るようにした
toshi.twice_decrement(2)
p toshi.age
p toshi.adult?
# p toshi.greet
# p toshi.hello
# p toshi.morning
# p Greet.hello
# p Greet.morning
