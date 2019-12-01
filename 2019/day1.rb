data = File.read('data/day1.txt').lines.map(&:to_i)

# Part 1
part1 = data.map do |mass|
  (mass / 3).floor - 2
end.reduce(&:+)

puts "Part 1: #{part1}"

# Part 2

def calculate_mass(mass)
  module_fuel = (mass / 3).floor - 2
  additional_fuel = module_fuel > 0 ? calculate_mass(module_fuel) : 0
  additional_fuel = additional_fuel < 0 ? 0 : additional_fuel

  module_fuel + additional_fuel
end

# Test data
# puts calculate_mass(14) -> 2
# puts calculate_mass(1969) -> 966
# puts calculate_mass(100756) -> 50346


part2 = data.map do |mass|
  calculate_mass(mass)
end.reduce(&:+)

puts "Part 2: #{part2}"
