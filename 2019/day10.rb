require 'matrix'

data = File.read('data/day10.txt')

class Map
  attr_accessor :columns, :lines, :tiles

  def initialize(data)
    @tiles = parse(data)
    @lines = data.lines.size
    @columns = data.lines.first.size
  end

  def most_asteroids
    counts = tiles.inject({}) do |memo, tile|
      memo[tile] = { visible: [] }
      (tiles - tile).each do |t|
        next if tile == [t[0], t[1]]

        if tile_visible?(tile, memo[tile][:visible], t)
          memo[tile][:visible] << t
        end
      end
      memo
    end

    counts.max_by do |(_, v)|
      v[:visible].size
    end
  end

  def shootout(stop = 200)
    counter = 0
    station = [28, 29] # calculated in #most_asteroids
    laser_initial_vector = Vector[0, -1]
    other_tiles = tiles - [station]

    info = other_tiles.inject({}) do |memo, tile|
      dxt = tile[0] - station[0]
      dyt = tile[1] - station[1]

      angle = laser_initial_vector.angle_with(Vector[dxt, dyt].normalize)
      angle = 2 * Math::PI - angle if tile[0] < station[0]
      memo[angle] ||= []
      memo[angle] << tile
      memo
    end.sort_by{ |(k, _)| k }.to_h

    info.transform_values! do |v|
      v.sort_by {|tile| (tile[0] - station[0]).abs + (tile[1] - station[1]).abs }
    end

    info.cycle do |k, v|
      next if info[k].nil?

      last = info[k].shift

      return last if counter == stop

      counter += 1
    end
  end

  private

  def tile_visible?(origin, visibles, tile)
    visibles.none? do |v|
      dxt = origin[0] - tile[0]
      dyt = origin[1] - tile[1]

      dxv = origin[0] - v[0]
      dyv = origin[1] - v[1]

      vt = Vector[dxt, dyt].normalize
      vv = Vector[dxv, dyv].normalize

      vt.angle_with(vv).zero?
    end
  end

  def parse(data)
    @tiles = data.lines.each_with_index.inject([]) do |memo, (line, y)|
      line.chars.each_with_index do |tile, x|
        memo << [x, y] if tile == '#'
      end
      memo
    end
  end
end

m = Map.new(data)
most = m.most_asteroids
puts "Part 1: #{most[1][:visible].count}"

asteroid200 = m.shootout(200)
puts "Part 2: #{asteroid200[0] * 100 + asteroid200[1]}"
