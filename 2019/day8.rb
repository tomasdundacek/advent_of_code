require 'colored2'

data = File.read('data/day8.txt').chomp.chars.map(&:to_i)
WIDTH = 25
HEIGHT = 6

class Image
  BLACK = 0
  WHITE = 1
  TRANSPARENT = 2

  def initialize(data, width, height)
    @data = data
    @width = width
    @height = height
  end

  def checksum
    min_group = layers.min_by { |a| a.count(0) }
    min_group.count(1) * min_group.count(2)
  end

  def draw
    (0...(WIDTH * HEIGHT)).each do |index|
      case visible_layer[index]
      when BLACK then print '*'.black
      when WHITE then print '*'.white
      end
      print "\n" if index % 25 == 24
    end
  end

  private

  def visible_layer
    @visible_layer ||= (0...(WIDTH * HEIGHT)).map do |index|
      layers.find do |l|
        l[index] != TRANSPARENT
      end[index]
    end
  end

  def layers
    @layers ||= @data.each_slice(@width * @height).to_a
  end
end

i = Image.new(data, WIDTH, HEIGHT)
puts "Part 1: #{i.checksum}"
puts "Part 2"
i.draw
