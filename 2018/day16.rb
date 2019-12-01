require 'set'

data = File.read('data/day16.txt').lines.map(&:chomp)
tests = data.shift(3220)
program = data.reject(&:empty?).map do |line|
  line.split(' ').map(&:to_i)
end

sets = []
$registers = []

until tests.empty?
  info = tests.shift(3)
  sets << {
    before_state: info[0].match(/Before: \[(.*)\]/)[1].split(', ').map(&:to_i),
    command:      info[1].split(' ').map(&:to_i),
    after_state:  info[2].match(/After:  \[(.*)\]/)[1].split(', ').map(&:to_i),
  }

  tests.shift
end

METHODS = %i[addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr].freeze

def addr(regA, regB, regC)
  $registers[regC] = $registers[regA] + $registers[regB]
end

def addi(regA, valB, regC)
  $registers[regC] = $registers[regA] + valB
end

def mulr(regA, regB, regC)
  $registers[regC] = $registers[regA] * $registers[regB]
end

def muli(regA, valB, regC)
  $registers[regC] = $registers[regA] * valB
end

def banr(regA, regB, regC)
  $registers[regC] = $registers[regA] & $registers[regB]
end

def bani(regA, valB, regC)
  $registers[regC] = $registers[regA] & valB
end

def borr(regA, regB, regC)
  $registers[regC] = $registers[regA] | $registers[regB]
end

def bori(regA, valB, regC)
  $registers[regC] = $registers[regA] | valB
end

def setr(regA, _, regC)
  $registers[regC] = $registers[regA]
end

def seti(valA, _, regC)
  $registers[regC] = valA
end

def gtir(valA, regB, regC)
  $registers[regC] = valA > $registers[regB] ? 1 : 0
end

def gtri(regA, valB, regC)
  $registers[regC] = $registers[regA] > valB ? 1 : 0
end

def gtrr(regA, regB, regC)
  $registers[regC] = $registers[regA] > $registers[regB] ? 1 : 0
end

def eqir(valA, regB, regC)
  $registers[regC] = valA == $registers[regB] ? 1 : 0
end

def eqri(regA, valB, regC)
  $registers[regC] = $registers[regA] == valB ? 1 :0
end

def eqrr(regA, regB, regC)
  $registers[regC] = $registers[regA] == $registers[regB] ? 1 : 0
end

def test(func, input, before, after)
  $registers = before

  method(func).call(*input)

  after == $registers
end

## PART A
counts = sets.dup.map do |set|
  selected = METHODS.select do |m|
    test(m, set[:command][1..-1], set[:before_state].dup, set[:after_state].dup)
  end

  selected.count >= 3 ? true : nil
end

puts "Solution 16a: #{counts.compact.count}"

## PART B
default_counts = Hash[METHODS.map { |m| [m, Set.new] }]

candidates = sets.dup.each_with_object(default_counts) do |set, memo|
  selected = METHODS.select do |m|
    test(m, set[:command][1..-1], set[:before_state].dup, set[:after_state].dup)
  end.each do |m|
    memo[m] << set[:command][0]
  end
end

opcodes = {}
loop do
  candidates.select do |_, possible|
    possible.size == 1
  end.each do |m, opcodes_set|
    opcodes[opcodes_set.first] = m
    candidates.delete(m)
  end

  candidates = candidates.map do |m, opcodes_set|
    [m, opcodes_set - opcodes.keys]
  end.to_h

  break if candidates.empty?
end

$registers = [0, 0, 0, 0]

program.each do |command|
  method(opcodes[command.shift]).call(*command)
end

puts "Solution 16b: #{$registers[0]}"
