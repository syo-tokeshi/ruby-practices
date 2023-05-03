def normal(num = 1)
  yield(num)
end

def samle_func
  yield
end

def magic_yield(num)
  if num > 3
    yield(num * 2)
  else
    yield(num)
  end
end

p magic_yield(5){ |magic_num|
  "私が受け取った数は#{magic_num}です"
}

p magic_yield(2){ |magic_num|
  "私が受け取った数は#{magic_num}です"
}

# def callbacl_func(message)
#   "I'm call back func. recive #{message}!!"
# end
#
# p samle_func {
#   callbacl_func("受けって、私の気持ち")
# }

# normal { |arg|
#   p 12 + arg
# }
#
# normal(2) { |arg|
#   p 12 + arg
# }