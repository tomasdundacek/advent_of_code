data = File.read('data/day2.txt').split(',').map(&:to_i)

def comp(ary)
  pos = 0
  opcode = ary[pos]

  while opcode != 99
    case opcode
    when 1 then ary[ary[pos+3]] = (ary[ary[pos+1]] || 0) + (ary[ary[pos+2]] || 0)
    when 2 then ary[ary[pos+3]] = (ary[ary[pos+1]] || 0) * (ary[ary[pos+2]] || 0)
    end

    pos += 4
    opcode = ary[pos]
  end

  ary
end

# Part 1
part1 = data.dup
part1[1] = 12
part1[2] = 2

puts "Part 1: #{comp(part1)[0]}"

#Part 2
TERMINAL = 19690720
MAX = 1_000

(0..MAX).each do |verb|
  (0..MAX).each do |noun|
    part2 = data.dup
    part2[1] = noun
    part2[2] = verb

    if comp(part2)[0] == TERMINAL
      puts "Part 2: #{100 * noun + verb}"
      return
    end
  end
end
