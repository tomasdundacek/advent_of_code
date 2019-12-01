FREQUENCY_DELTAS = File.read('data/day1.txt').lines.map(&:to_i).freeze

puts 'Solution 1a - final frequency'
puts FREQUENCY_DELTAS.sum

puts 'Solution 1b - first frequency seen twice'

FREQUENCY_DELTAS.cycle.inject(current: 0, seen: []) do |memo, delta|
  memo[:current] += delta

  if memo[:seen].include?(memo[:current])
    puts memo[:current]
    break
  else
    memo[:seen] << memo[:current]
  end

  memo
end
