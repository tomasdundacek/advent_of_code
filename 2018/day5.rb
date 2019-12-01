data_polymer = File.read('data/day5.txt').chomp

def polymer_length(polymer)
  characters = polymer.chars.uniq.map(&:downcase).uniq.sort
  regexp = Regexp.new(characters.map { |c| "#{c}#{c.upcase}|#{c.upcase}#{c}" }.join('|'))

  loop { break unless polymer.gsub!(regexp, '') }

  polymer.length
end

# Part A
puts "Solution 5a: #{polymer_length(data_polymer)}"

# Part B
characters = data_polymer.chars.uniq.map(&:downcase).uniq.sort

removed_char_stats = characters.map do |character|
  test_polymer = data_polymer.gsub(/#{character}/i, '')
  [character, polymer_length(test_polymer)]
end.to_h

puts "Solution 5b: #{removed_char_stats.min_by{ |k,v| v }[1]}"

# This method takes a lot of time ;) I leave it here just to show which was my
# initial approach and which way not to go
# def polymer_length(polymer)
#   found = true
#   while(found)
#     polymer.each_char.each_with_index do |char, index|
#       if char == polymer[index + 1]&.swapcase
#         found = true
#         polymer.slice!(index, 2)
#         puts polymer.length # (debug so that you know it hasn't stuck)
#         break
#       else
#         found = false
#       end
#     end
#   end
#   polymer.length
# end