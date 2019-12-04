data = File.read('data/day3.txt').lines.map { |l| l.chomp.split(',') }

# data = [ # 1) 159, 2) 610
#   %w[R75 D30 R83 U83 L12 D49 R71 U7 L72],
#   %w[U62 R66 U55 R34 D71 R55 D58 R83]
# ]

# data = [ # 1) 135, 2) 410
#   %w[R98 U47 R26 D63 R33 U87 L62 D20 R33 U53 R51],
#   %w[U98 R91 D20 R16 D67 R40 U7 R15 U6 R7]
# ]

initial = Array.new(data.size) { [[0, 0]] }

lines_points = data.each_with_index.inject(initial) do |memo, (line, index)|
  pos = [0, 0]

  line.each do |info|
    dir = info[0]
    len = info[1..-1].to_i

    direction = case dir
                when 'U' then [0, 1]
                when 'D' then [0, -1]
                when 'L' then [-1, 0]
                when 'R' then [1, 0]
                end

    len.times do
      pos = pos.map.with_index { |p, i| p + direction[i] }
      memo[index] << pos
    end
  end

  memo
end

crossing_points = (lines_points[0] & lines_points[1]) - [[0, 0]]
puts "Part 1: #{crossing_points.min_by { |p| p.map(&:abs).sum }.map(&:abs).sum}"

# Part 2
# Smallest number of steps to each intersection and minimal sum of it
nearest_crossing_steps = crossing_points.map do |point|
  [point, lines_points[0].index(point) + lines_points[1].index(point)]
end.min_by { |p| p[1] }[1]

puts "Part 2: #{nearest_crossing_steps}"
