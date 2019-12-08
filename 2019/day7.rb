require_relative './lib/intcode'

ary = File.read('data/day7.txt').split(',').map(&:to_i)
# ary = [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
#   -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
#   53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]
PHASES_1 = Array(0..4).permutation.freeze
PHASES_2 = Array(5..9).permutation.freeze

# Part 2

maxes_1 = PHASES_1.map do |phases|
  puts phases.inspect
  input = 0

  phases.each do |phase|
    input = IntCode.new(ary.dup, [phase, input], debug: false).run
  end

  [phases, input]
end

max_1 = maxes_1.max_by{ |i| i[1] }

# Part 2

maxes_2 = PHASES_2.map do |phases|
  computers = phases.map do |phase|
    IntCode.new(ary.dup, [phase], feedback_mode: true, debug: false)
  end
  computers[0].inputs << 0 # default input
  output = 0

  (0..4).cycle do |i|
    output = computers[i].run
    computers[(i + 1) % 5].inputs << output if output

    break if computers[4].halted
  end
  [phases, output]
end

max_2 = maxes_2.max_by{ |i| i[1] }

puts "Part 1: Phase - #{max_1[0]} = #{max_1[1]}"
puts "Part 2: Phase - #{max_2[0]} = #{max_2[1]}"
