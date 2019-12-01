require 'matrix'

GRID_NUMBER = 1718

class Grid
  SIZE = 300
  attr_accessor :grid, :grid_number

  def initialize(grid_number)
    @grid_number = grid_number
    @grid = {}

    build!
  end

  def biggest_square(size)
    max_position = SIZE - size
    square_grid = {}
    (0..max_position).flat_map do |x|
      (0..max_position).map do |y|
        square_grid[[x, y]] = @grid.minor(x...x+size, y...y+size).sum
      end
    end

    square_grid.max_by{|_, val| val}
  end

  private

  def power_level(x, y)
    subtotal =  rack_id = x + 10
    subtotal *= y
    subtotal += @grid_number
    subtotal *= rack_id
    subtotal =  subtotal.to_s.chars.map(&:to_i)[-3]
    subtotal -  5
  end

  def build!
    ary = (1..SIZE).map do |x|
      (1..SIZE).flat_map do |y|
        power_level(x, y)
      end
    end

    @grid = Matrix[*ary]
  end
end

g = Grid.new(GRID_NUMBER)
puts "Solution 11a: #{g.biggest_square(3)[0].map{|a| a + 1}}"

square_sizes = (1..300).map do |size|
  biggest = g.biggest_square(size)
  # puts "Done: #{size / 300.to_f}"

  [[*biggest[0], size], biggest[1]]
end

result = square_sizes.to_h.max_by { |_, val| val }[0]
puts "Solution 11b: #{result[0]+1},#{result[1]+1},#{result[2]}"
