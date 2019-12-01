require 'matrix'
require 'pry'
require 'colored2'

DATA = File.read('data/day13.txt').lines.map(&:chomp).freeze

class Track
  attr_accessor :parts, :carts, :removal
  class Crash < StandardError
    attr_accessor :crash_position

    def initialize(crash_position = nil)
      super("Crash at #{crash_position}!")
      self.crash_position = crash_position
    end
  end

  # turn namings for carts going upwards
  PARTS = {
    intersection:    %w[+],
    right_turn:      %w[/],
    left_turn:       %w[\\],
    vertical_road:   %w[|],
    horizontal_road: %w[-],
    cart:            %w[< ^ > v]
  }.freeze

  def initialize(data, removal: false)
    @data = data
    @parts = {}
    @carts = []
    @removal = removal
  end

  def build!
    @parts = @data.each_with_object({}).with_index do |(line, parts), y|
      line.chars.each_with_index do |part, x|
        track_part = recognize_part!(part)
        next unless track_part

        parts[[x, y]] = track_part[:track]

        if track_part[:cart_direction]
          @carts << Cart.new(x, y, track_part[:cart_direction], self)
        end
      end
      parts
    end
  end

  def tick!
    @carts.sort_by{|a| a.position.to_a}.each_with_index do |cart, index|
      # next if cart.crashed

      begin
        cart.move!
      rescue Track::Crash => e
        if @removal
          remove_crashed_carts!
        else
          raise
        end
      end
    end
  end

  def show!
    output = ''
    @data.each_with_index do |line, y|
      line.chars.each_with_index do |part, x|
        output += (cart_direction_symbol_at(x, y)&.red&.on&.blue || PARTS[@parts[[x, y]]]&.first || ' ')
        $stdout.flush
      end
      output += "\n"
    end
    system('clear')
    puts output
  end

  private

  def remove_crashed_carts!
    @carts.delete_if { |cart| cart.crashed }
  end

  def cart_direction_symbol_at(x, y)
    cart = @carts.find { |cart| cart.position.to_a == [x, y] }
    return unless cart

    PARTS[:cart][Cart::MOVEMENTS.values.index(cart.direction)]
  end

  def recognize_part!(symbol)
    part = PARTS.find { |key, symbols| symbols.include?(symbol) }
    return unless part

    case part[0]
    when :cart then {
      track: %i[up down].include?(cart_direction(symbol)) ? :vertical_road : :horizontal_road,
      cart_direction: cart_direction(symbol)
    }
    else { track: part[0] }
    end
  end

  def cart_direction(symbol)
    Cart::MOVEMENTS.keys[PARTS[:cart].index(symbol)]
  end
end

class Cart
  MOVEMENTS = {
    left:  Vector[-1, 0].freeze,
    up:    Vector[0, -1].freeze,
    right: Vector[1, 0].freeze,
    down:  Vector[0, 1].freeze
  }.freeze

  INTERSECTION_DECISIONS = %i[left straight right].freeze

  attr_accessor :position, :direction, :crashed

  def initialize(x, y, direction, track)
    @position = Vector[x, y]
    @direction = MOVEMENTS[direction]
    @track = track
    @intersection_decision = :left
    @crashed = false
  end

  def move!
    @position += @direction

    if crashed?
      @crashed = true
      # binding.pry
      @track.carts.each do |cart|
        cart.crashed = true if cart.position == @position
      end
      raise Track::Crash.new(@position)
    end

    evaluate_turn!
    self
  end

  def crashed?
    (@track.carts - [self]).map(&:position).any? { |pos| pos == @position }
  end

  private

  def current_track_part
    @track.parts[@position.to_a]
  end

  def evaluate_turn!
    case current_track_part
    when :intersection then turn_on_intersection!
    when :right_turn   then turn_on_right_turn!
    when :left_turn    then turn_on_left_turn!
    end
  end

  def turn_on_intersection!
    case @intersection_decision
    when :left then turn_left!
    when :right then turn_right!
    end

    current_index = INTERSECTION_DECISIONS.index(@intersection_decision)
    @intersection_decision =
      INTERSECTION_DECISIONS[(current_index + 1) % 3]
  end

  def turn_on_left_turn!
    @direction = case @direction
                 when MOVEMENTS[:up]    then MOVEMENTS[:left]
                 when MOVEMENTS[:right] then MOVEMENTS[:down]
                 when MOVEMENTS[:down]  then MOVEMENTS[:right]
                 when MOVEMENTS[:left]  then MOVEMENTS[:up]
                 end
  end

  def turn_left!
    @direction = case @direction
                 when MOVEMENTS[:up]    then MOVEMENTS[:left]
                 when MOVEMENTS[:right] then MOVEMENTS[:up]
                 when MOVEMENTS[:down]  then MOVEMENTS[:right]
                 when MOVEMENTS[:left]  then MOVEMENTS[:down]
                 end
  end

  def turn_on_right_turn!
    @direction = case @direction
                 when MOVEMENTS[:up]    then MOVEMENTS[:right]
                 when MOVEMENTS[:right] then MOVEMENTS[:up]
                 when MOVEMENTS[:down]  then MOVEMENTS[:left]
                 when MOVEMENTS[:left]  then MOVEMENTS[:down]
                 end
  end

  def turn_right!
    @direction = case @direction
                 when MOVEMENTS[:up]    then MOVEMENTS[:right]
                 when MOVEMENTS[:right] then MOVEMENTS[:down]
                 when MOVEMENTS[:down]  then MOVEMENTS[:left]
                 when MOVEMENTS[:left]  then MOVEMENTS[:up]
                 end
  end
end

t = Track.new(DATA.dup)
t.build!
(1..Float::INFINITY).each do |i|
  begin
    t.tick!
  rescue Track::Crash => e
    # system('clear')
    # t.show!
    # puts "Tick: #{i}"
    puts "Solution 13a: #{e.crash_position.to_a}"
    break
  end
end

t = Track.new(DATA.dup, removal: true)
t.build!

(1..Float::INFINITY).each do |i|
  t.tick!
  # if i >= 0
    # system('clear')
    # t.show!
    # puts "Tick: #{i}"
    # sleep 2
  # end
  if t.carts.size == 1
    # system('clear')
    # t.show!
    # puts "Tick: #{i}"
    puts "Solution 13b: #{t.carts.first.position.to_a}"
    break
  end
end