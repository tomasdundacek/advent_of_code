LINES = File.read('data/day3.txt').lines.map(&:chomp).freeze
DATA_REGEXP = /^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)$/.freeze

DATA = LINES.map do |line|
  line.match(DATA_REGEXP) do |data|
    {
      id:    data[1].to_i,
      x_min: data[2].to_i,
      y_min: data[3].to_i,
      x_max: data[2].to_i + data[4].to_i - 1,
      y_max: data[3].to_i + data[5].to_i - 1
    }
  end
end.freeze

def overlap?(range1, range2)
  range1.cover?(range2.first) || range2.cover?(range1.first)
end

# PART 1
matrix = Hash.new(0)

DATA.each do |rect|
  x_range = (rect[:x_min]..rect[:x_max])
  y_range = (rect[:y_min]..rect[:y_max])

  x_range.each do |x|
    y_range.each do |y|
      matrix[[x, y]] += 1
    end
  end
end

puts "Solution 3a: #{matrix.select { |_, v| v > 1 }.count}"

# PART 2
DATA.each_with_index do |rect1, index|
  x1_range = (rect1[:x_min]..rect1[:x_max])
  y1_range = (rect1[:y_min]..rect1[:y_max])
  overlapped = false

  (0...DATA.size).each do |i|
    next if index == i

    rect2 = DATA[i]
    x2_range = (rect2[:x_min]..rect2[:x_max])
    y2_range = (rect2[:y_min]..rect2[:y_max])

    if overlap?(x1_range, x2_range) && overlap?(y1_range, y2_range)
      overlapped = true
      break
    end
  end

  unless overlapped
    puts "Solution 3b: #{rect1[:id]}"
    break
  end
end
