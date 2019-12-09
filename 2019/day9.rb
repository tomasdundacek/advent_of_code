require_relative './lib/intcode'

ary = File.read('data/day9.txt').chomp.split(',').map(&:to_i)

# ary = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99] # copy of itself
# ary = [1102,34915192,34915192,7,4,7,99,0] # => 1219070632396864
# ary = [104,1125899906842624,99] # => 1125899906842624

IntCode.new(ary, [1]).run
