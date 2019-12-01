LABELS = File.read('data/day2.txt').lines.map(&:chomp).freeze

# Part 1
def character_occurences(str)
  str.chars.group_by(&:itself).transform_values(&:count)
end

checksum_values = LABELS.inject(two: 0, three: 0) do |memo, label|
  stats = character_occurences(label)

  memo[:two] += 1 if stats.value?(2)
  memo[:three] += 1 if stats.value?(3)
  memo
end

puts "Checksum: #{checksum_values[:two] * checksum_values[:three]}"

# Part 2

def diff_by_one?(str1, str2)
  diff = 0
  (0...str1.length).each do |i|
    diff += 1 unless str1[i] == str2[i]
    return false if diff > 1
  end
  true
end

puts 'Most similar labels - equal characters'
LABELS.each_with_index do |label, index|
  LABELS[(index + 1)...LABELS.size].each do |other|
    next unless diff_by_one?(label, other)

    ary = label.chars.each_with_index.map do |char, i|
      char if char == other[i]
    end
    puts ary.join
  end
end