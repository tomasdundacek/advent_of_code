require 'pry'

MIN = 278_384
MAX = 824_795

def adjacent_double?(ary)
  (0...ary.size - 1).any? do |index|
    ary[index] == ary[index + 1]
  end
end

filtered = (MIN..MAX).filter do |num|
  num_ary = num.digits.reverse

  next unless num_ary.sort == num_ary
  next unless adjacent_double?(num_ary)

  num
end

puts "Part 1: #{filtered.size}" # 921

def adjacent_double_2?(ary)
  group = nil
  group_size = 0

  ary.each do |num|
    if num != group
      return true if group_size == 2

      group_size = 0
      group = num
    end

    group_size += 1
  end
  group_size == 2
end

filtered2 = filtered.filter do |num|
  num_ary = num.digits.reverse

  next unless adjacent_double_2?(num_ary)

  num
end

puts "Part 2: #{filtered2.size}" # 603
