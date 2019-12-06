$ary = File.read('data/day5.txt').split(',').map(&:to_i)

def ops(code)
  opcode = code % 100
  mode1 = (code / 100)    % 10 == 0 ? :position : :value
  mode2 = (code / 10_00)  % 10 == 0 ? :position : :value
  mode3 = (code / 10_000) % 10 == 0 ? :position : :value

  [opcode, mode1, mode2, mode3]
end

def opcode_len(opcode)
  {
    1 => 4,
    2 => 4,
    3 => 2,
    4 => 2,
    5 => 3,
    6 => 3,
    7 => 4,
    8 => 4
  }[opcode]
end

def position(index)
  $ary[index]
end

def value(value)
  value
end

pos = 0
pos_modified = nil
opcode, mode1, mode2, = ops($ary[pos])

while opcode != 99
  # puts $ary.inspect
  # puts "Pos: #{pos}"
  # puts "Opcode: #{opcode}"
  # puts "Len: #{opcode_len(opcode)}"
  # puts "==="

  case opcode
  when 1 then $ary[$ary[pos+3]] = (method(mode1).call($ary[pos + 1] || 0)) + (method(mode2).call($ary[pos + 2] || 0))
  when 2 then $ary[$ary[pos+3]] = (method(mode1).call($ary[pos + 1] || 0)) * (method(mode2).call($ary[pos + 2] || 0))
  when 3 then
    puts "Input, pls: "
    $ary[$ary[pos+1]] = gets.chomp.to_i
  when 4 then puts method(mode1).call($ary[pos + 1])
  when 5 then
    if method(mode1).call($ary[pos + 1]) != 0
      pos = method(mode2).call($ary[pos + 2])
      pos_modified = true
    end
  when 6
    if method(mode1).call($ary[pos + 1]) == 0
      pos = method(mode2).call($ary[pos + 2])
      pos_modified = true
    end
  when 7
    if method(mode1).call($ary[pos + 1]) < method(mode2).call($ary[pos + 2])
      $ary[$ary[pos + 3]] = 1
    else
      $ary[$ary[pos + 3]] = 0
    end
  when 8
    if method(mode1).call($ary[pos + 1]) == method(mode2).call($ary[pos + 2])
      $ary[$ary[pos + 3]] = 1
    else
      $ary[$ary[pos + 3]] = 0
    end
  end

  pos += opcode_len(opcode) unless pos_modified

  opcode, mode1, mode2, = ops($ary[pos])
  pos_modified = false
end

# Part 1 - run with input 1: 13346482
# Part 2 - run with input 5: 12111395
