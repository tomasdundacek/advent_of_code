require 'matrix'

LINES  = File.read('data/day10.txt').lines.map(&:chomp).freeze
REGEXP = /position=<([ -]*\d{1,}),([ -]*\d{1,})> velocity=<([ -]*\d{1,}),([ -]*\d{1,})>/.freeze

class Point
  attr_accessor :x, :y, :velocity

  def initialize(x, y, velocity)
    @x = x
    @y = y
    @velocity = Vector.elements(velocity)
  end

  def move!(times = 1)
    new_position = Vector.elements([@x, @y]) + (velocity * times)

    @x, @y = new_position.to_a
    self
  end
end

points = LINES.map do |line|
  line.match(REGEXP) do |matchdata|
    Point.new(matchdata[1].to_i, matchdata[2].to_i, matchdata[3..4].map(&:to_i))
  end
end

def smallest_square(points)
  max = 50000
  sizes = (0..max).to_a.map do |t|
    # puts t/max.to_f if (t % 1000).zero? # debug
    x_min = points.min_by(&:x).x
    y_min = points.min_by(&:y).y
    x_max = points.max_by(&:x).x
    y_max = points.max_by(&:y).y

    points.each(&:move!)
    rectangle_size(x_min, x_max, y_min, y_max)
  end

  min = sizes.index(sizes.min)
  puts "Solution 10b: #{min}"
  points.map! { |p| p.move!(min - max - 1) }
end

def rectangle_size(x_min, x_max, y_min, y_max)
  (x_max - x_min) * (y_max - y_min)
end

class DrawBoard
  attr_accessor :strategy

  def initialize(points, strategy)
    @points   = points
    @strategy = strategy.new(points)
  end

  def run!
    @strategy.call(@points)
  end
end

class TextStrategy
  def initialize(points)
    @x_min = points.min_by(&:x).x
    @y_min = points.min_by(&:y).y
    @x_max = points.max_by(&:x).x
    @y_max = points.max_by(&:y).y
  end


  def call(points)
    draw!(points)
  end

  private

  def draw!(points)
    (@y_min..@y_max).each do |y|
      (@x_min..@x_max).each do |x|
        point = points.detect {|p| p.x == x && p.y == y}
        print point.nil? ? '.' : '*'
        $stdout.flush
      end
      puts ""
    end
  end
end

smallest_square_points = smallest_square(points)
DrawBoard.new(smallest_square_points, TextStrategy).run!