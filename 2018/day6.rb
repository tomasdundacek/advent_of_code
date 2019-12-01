LINES = File.read('data/day6.txt').lines.map(&:chomp).freeze

coordinates = LINES.inject([]) do |memo, line|
  x, y = line.match(/(\d+), (\d+)/).captures.map(&:to_i)
  memo << { x: x, y: y }
end

def closest_to(x, y, coords:)
  sorted = coords.
    map { |c| { distance: distance_of_points([x, y], [c[:x], c[:y]]) , coordinate: c } }.
    sort_by { |c| c[:distance] }

  case sorted[0][:distance]
  when sorted[1][:distance] then nil
  else sorted[0][:coordinate]
  end
end

def distance_of_points(point1, point2)
  # 0 -> x, 1 -> y
  (point1[0] - point2[0]).abs + (point1[1] - point2[1]).abs
end

# Part 6A
x_ary = coordinates.map { |val| val[:x] }
y_ary = coordinates.map { |val| val[:y] }

# within these boundaries, we will search for most finite coordinate
x_min = x_ary.min
x_max = x_ary.max
y_min = y_ary.min
y_max = y_ary.max

# calculate closest coordinate to each point
points = {}
(x_min..x_max).each do |x|
  (y_min..y_max).each do |y|
    points[[x, y]] = closest_to(x, y, coords: coordinates)
  end
end

# Explanation for the select - any coordinate closest to any border point is
# infinite and needs to be removed
closest_to_most = points.
  group_by { |_, p| p }.
  select { |k, p| k && p.none? { |pp| ([x_min, x_max].include?(pp[0][0]) || [y_min, y_max].include?(pp[0][1])) }}.
  max_by { |_, v| v.count }[1].
  count

puts "Solution 6a: #{closest_to_most}"

# Part 6B
MAX_DISTANCE = 10_000

counter = 0
(x_min..x_max).each do |x|
  (y_min..y_max).each do |y|
    sum = coordinates.
      map {|c| distance_of_points([x, y], [c[:x], c[:y]]) }.
      reduce(:+)

    counter += 1 if sum < MAX_DISTANCE
  end
end

puts "Solution 6b: #{counter}"