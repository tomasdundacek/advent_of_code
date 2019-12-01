require 'matrix'
require 'pry'

tiles = File.read('data/day15.txt').lines.map(&:chomp).map(&:chars)

EnemiesNotAvailable = Class.new(StandardError)
ElfDeadError = Class.new(StandardError)

class Warrior
  INITIAL_HIT_POINTS = 200
  ATTACK_POWER = 3

  # directions in reading order (up, left, right, down)
  DIRECTIONS = [Vector[0, -1], Vector[-1, 0], Vector[1, 0], Vector[0, 1]].freeze

  attr_accessor :position, :hit_points

  def initialize(x, y, board)
    @position = Vector[x, y]
    @board = board
    @hit_points = INITIAL_HIT_POINTS
    @attack_power = ATTACK_POWER
  end

  def take_turn!
    move!
    attack!

    self
  end

  private

  def move!
    # 1. identify targets (all enemies)
    targets = @board.warriors.reject { |w| w.class.name == self.class.name }

    raise EnemiesNotAvailable if targets.empty?

    # 2. identify adjacent squares of all enemies ("in range")
    adjacent_tiles = targets.flat_map do |target|
      possible_tiles = self.class.adjacent_tiles(target.position)

      # the warrior is already in reach
      return if possible_tiles.include?(@position.to_a)

      possible_tiles.reject do |tile|
        @board.grid[tile]&.fetch(:type) == :wall || \
        @board.grid[tile]&.fetch(:occupied_by, nil)
      end
    end

    # 3. select reachable (= path not blocked)
    reachable_tiles = reachable_tiles_with_distance(@position.to_a)
    reachable = adjacent_tiles & reachable_tiles.keys

    # 4. select nearest (first in reading order - aka min <=>[x, y])
    nearest = reachable.
      group_by { |tile| reachable_tiles[tile] }.
      min_by { |distance, _| distance }&.[](1)

    return unless nearest

    # 5. move into one of these fields (in reading order)
    move_towards = nearest.sort_by {|a| [a[1], a[0]] }.first

    possible_tiles = self.class.adjacent_tiles(@position).reject do |tile|
      @board.grid[tile]&.fetch(:type) == :wall || \
      @board.grid[tile]&.fetch(:occupied_by, nil)
    end

    reachable = reachable_tiles_with_distance(move_towards)
    reachable_tiles = possible_tiles & reachable.keys

    if possible_tiles.include?(move_towards)
      reachable_tiles << move_towards
      reachable[move_towards] = 0
    end

    next_tile = reachable_tiles.
      group_by { |tile| reachable[tile] }.
      min_by { |distance, _| distance }[1].
      sort_by { |tile| [tile[1], tile[0]] }.
      first

    new_position = Vector[*next_tile]
    @board.grid[@position.to_a][:occupied_by] = nil
    @position = new_position
    @board.grid[@position.to_a][:occupied_by] = self
  end

  def attack!
    # 1. select opponent
    possible_targets = self.class.adjacent_tiles(@position).reject do |tile|
      # binding.pry if @position.to_a == [4, 2]
      @board.grid[tile]&.fetch(:type) == :wall || \
      @board.grid[tile]&.fetch(:occupied_by, nil).nil? || \
      @board.grid[tile]&.fetch(:occupied_by, nil).class.name == self.class.name
    end

    return if possible_targets.empty?

    # binding.pry if @position.to_a == [1, 1]
    # puts "#{@position} -> #{possible_targets.inspect}"
    target_tile = possible_targets.group_by do |tile|
      @board.grid[tile][:occupied_by].hit_points
    end.min[1].sort_by do |tile|
      [tile[1], tile[0]]
    end.first

    # 2. hit opponent
    target = @board.grid[target_tile][:occupied_by]
    target.hit_points -= @attack_power
    if target.hit_points <= 0
      raise ElfDeadError if target.class.name == 'Elf'
      @board.grid[target_tile][:occupied_by] = nil
      @board.warriors.delete(target)
    end
  end

  def self.adjacent_tiles(position)
    DIRECTIONS.map { |d| (position + d).to_a }
  end

  def reachable_tiles_with_distance(position)
    to_explore = [position]
    steps = {}

    (0..Float::INFINITY).each do |step|
      unless step == 0
        to_explore.each do |exp|
          steps[exp] = step unless exp == position
        end
      end

      to_explore = to_explore.uniq.flat_map do |tile|
        self.class.adjacent_tiles(Vector[*tile]).reject do |adj|
          @board.grid[adj]&.fetch(:type) == :wall || \
          @board.grid[adj]&.fetch(:occupied_by, nil) || \
          steps.key?(adj)
        end
      end
      break if to_explore.empty?
    end

    steps
  end

  private

  def distance_to(x, y)
    (@position[0] - x).abs + (@position[1] - y).abs
  end
end

class Elf < Warrior
  def initialize(x, y, board, attack_power:)
    super(x, y, board)
    @attack_power = attack_power
  end

  def to_s
    'E'
  end
end

class Goblin < Warrior
  def to_s
    'G'
  end
end

class Board
  WALL = '#'.freeze
  GROUND = '.'.freeze

  attr_accessor :warriors, :grid, :rounds_completed

  def initialize(tiles_array, elf_attack_power: 3)
    @warriors = []
    @elf_attack_power = elf_attack_power
    @tiles = build!(tiles_array)
    @rounds_completed = 0
  end

  def to_s
    output = ''
    x_max = @tiles.max_by { |key, _| key[0] }[0][0]
    y_max = @tiles.max_by { |key, _| key[1] }[0][1]

    (0..y_max).each do |y|
      warriors_in_line = []
      (0..x_max).each do |x|
        output << if @tiles[[x, y]][:occupied_by]
                    warriors_in_line << @tiles[[x, y]][:occupied_by]
                    @tiles[[x, y]][:occupied_by].to_s
                  else
                    case @tiles[[x, y]][:type]
                    when :wall then WALL
                    when :ground then GROUND
                    end
                  end
      end
      output << ' '
      output << warriors_in_line.map { |w| "#{w.to_s}(#{w.hit_points})" }.join(' ')
      output << "\n"
    end
    output
  end

  def do_round!
    warriors = @warriors.dup
    warriors.each do |w|
      w.take_turn! if @warriors.include?(w)
      # binding.pry if @rounds_completed == 33 && w.position.to_a == [1, 2]
      # binding.pry if @rounds_completed == 34 && w.class.name == 'Elf'
    end

    @warriors.sort_by! {|w| w.position.to_a.reverse}
    @rounds_completed += 1
  end

  private

  def build!(tiles_array)
    @grid = tiles_array.each_with_object({}).with_index do |(tiles_line, grid), y|
      tiles_line.each.with_index do |tile, x|
        tile = build_tile!(tile, x, y)
        grid[[x, y]] = tile
      end
    end
  end

  def build_tile!(tile, x, y)
    result = case tile
             when '#' then return { type: :wall }
             when 'E' then { occupied_by: build_warrior!(x, y, type: :elf) }
             when 'G' then { occupied_by: build_warrior!(x, y, type: :goblin) }
             else {}
             end.merge(type: :ground)

    @warriors << result[:occupied_by] if result[:occupied_by]
    result
  end

  def build_warrior!(x, y, type:)
    if type == :elf
      Elf.new(x, y, self, attack_power: @elf_attack_power)
    else
      Goblin.new(x, y, self)
    end
  end
end

# b = Board.new(tiles)
# puts b.to_s
# begin
#   (1..Float::INFINITY).each do |round|
#     b.do_round!
#     system('clear')
#     puts b.to_s
#     puts "round #{round}"
#     sleep 0.2
#   end
#   rescue EnemiesNotAvailable
#     system('clear')
#     puts b.to_s
#     puts "Solution 15a: #{b.rounds_completed * b.warriors.sum{|w| w.hit_points}}"
# end

(1..Float::INFINITY).each do |elf_attack_power|
  b = Board.new(tiles.dup, elf_attack_power: elf_attack_power)
  begin
    (1..Float::INFINITY).each do |round|
        b.do_round!
        system('clear')
        puts b.to_s
        puts "round #{round}"
        puts "EAP: #{elf_attack_power}"
        sleep 0.1
    end
  rescue EnemiesNotAvailable
    system('clear')
    puts b.to_s
    puts "Solution 15b: #{b.rounds_completed * b.warriors.sum{|w| w.hit_points}}"
    break
  rescue ElfDeadError
    next
  end
end