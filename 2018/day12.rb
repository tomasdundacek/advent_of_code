LINES = File.read('data/day12.txt').lines.map(&:chomp)

PATTERNS = LINES[2..-1].
  map { |l| l.split(' => ')}.
  to_h
INITIAL_STATE = LINES[0].split[2]

class PlantGrid
  PLANT = '#'.freeze
  EMPTY = '.'.freeze
  BECOMING_PLANT = 'X'.freeze
  BECOMING_EMPTY = 'O'.freeze

  CLEANING_PATTERN = Regexp.new("[#{PLANT}#{BECOMING_EMPTY}#{BECOMING_PLANT}]").freeze

  def initialize(initial_state, patterns)
    @state = initial_state.dup

    @changing_pattern = patterns.
      dup.
      reject! { |key, val| key[2] == val }.
      map do |key, _|
        escaped = key.chars.map { |a| a.gsub('.', '\.')}
        "(?<=#{escaped[0..1].join})(#{escaped[2]})(?=#{escaped[3..4].join})"
      end.join('|')
    @changing_pattern = Regexp.new(@changing_pattern).freeze
    @remaining_pattern = patterns.
      dup.
      reject! { |key, val| key[2] != val }.
      map do |key, _|
        escaped = key.chars.map { |a| a.gsub!('.', '[\.X]'); a.gsub('#', '[#O]') }
        "(?<=#{escaped[0..1].join})(#{escaped[2]})(?=#{escaped[3..4].join})"
      end.join('|')
    @remaining_pattern = Regexp.new(@remaining_pattern).freeze
  end

  def move(steps = 1)
    leftmost_plant_index = @state.index('#')
    (1..steps).each do |s|
      starting = @state.dup
      @state = @state.prepend('....').concat('....')

      @state = @state.gsub(@changing_pattern, EMPTY => BECOMING_PLANT,
                                              PLANT => BECOMING_EMPTY)

      @state = @state.gsub(@remaining_pattern, PLANT => BECOMING_PLANT,
                                               EMPTY => BECOMING_EMPTY)

      @state = @state.gsub(CLEANING_PATTERN, PLANT => EMPTY,
                                             BECOMING_EMPTY => EMPTY,
                                             BECOMING_PLANT => PLANT)

      leftmost_plant_index += (@delta = (@state.index(PLANT) - 4))

      @state = @state[@state.index(PLANT)..@state.rindex(PLANT)]

      @last_step = s
      break if starting == @state
    end

    @state.
      chars.
      map.
      with_index do |char, index|
        char == PLANT ? (index + leftmost_plant_index + (steps - @last_step) * @delta) : nil
      end.reject!(&:nil?).sum
  end
end

p = PlantGrid.new(INITIAL_STATE, PATTERNS)

puts "Solution 12a: #{p.move(20)}"

p = PlantGrid.new(INITIAL_STATE, PATTERNS)
puts "Solution 12b: #{p.move(50_000_000_000)}"