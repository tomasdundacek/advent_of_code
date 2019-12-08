require_relative './lib/intcode'

ary = File.read('data/day5.txt').split(',').map(&:to_i)

# # Part 1 - run with input 1: 13346482
# # Part 2 - run with input 5: 12111395

puts "Part 1"
IntCode.new(ary.dup, [1]).run #=> 13346482

puts "Part 2"
IntCode.new(ary.dup, [5]).run #=> 12111395
