class IntCode
  OPCODES = [nil, :add, :multiply, :input, :output, :jump_if_true, :jump_if_false, :less_than, :equal, :adjust_relative_base].freeze
  LENGTHS = [nil, 4, 4, 2, 2, 3, 3, 4, 4, 2].freeze

  attr_accessor :code, :debug, :halted, :feedback_mode, :inputs, :pos,
                :pos_modified, :relative_base

  def initialize(code = [], inputs = [], feedback_mode: false, debug: false)
    @code = code
    @inputs = inputs
    @pos = 0
    @pos_modified = false
    @debug = debug
    @feedback_mode = feedback_mode
    @relative_base = 0
    @halted = false
  end

  def run
    opcode, *modes = ops(code[pos])

    while opcode != 99
      params = code[(pos + 1)..(pos + LENGTHS[opcode] - 1)]

      break if opcode == 3 && inputs.empty? && feedback_mode

      if debug
        puts code.inspect
        puts "Pos: #{pos}"
        puts "Opcode: #{opcode}"
        puts "Len: #{LENGTHS[opcode]}"
        puts "Params: #{params}"
        puts "Modes: #{modes[0...params.size]}"
        puts "Relative base: #{relative_base}"
        puts "==="
      end

      method(OPCODES[opcode]).call(params, modes)

      @pos += LENGTHS[opcode] unless pos_modified

      break if opcode == 4 && feedback_mode

      opcode, *modes = ops(code[pos])
      @pos_modified = false
    end

    @halted = true if opcode == 99
    [4, 99].include?(opcode) ? @last_output : nil
  end

  private

  def add(params, modes)
    pos = store_index(params[2], modes[2])
    code[pos] = number(params[0], modes[0]) + number(params[1], modes[1])
  end

  def multiply(params, modes)
    pos = store_index(params[2], modes[2])
    code[pos] = number(params[0], modes[0]) * number(params[1], modes[1])
  end

  def input(params, modes)
    pos = store_index(params[0], modes[0])
    code[pos] = inputs.shift
  end

  def output(params, modes)
    puts(@last_output = number(params[0], modes[0]))
  end

  def jump_if_true(params, modes)
    if number(params[0], modes[0]) != 0
      @pos = number(params[1], modes[1])
      @pos_modified = true
    end
  end

  def jump_if_false(params, modes)
    if number(params[0], modes[0]) == 0
      @pos = number(params[1], modes[1])
      @pos_modified = true
    end
  end

  def less_than(params, modes)
    pos = store_index(params[2], modes[2])
    if number(params[0], modes[0]) < number(params[1], modes[1])
      code[pos] = 1
    else
      code[pos] = 0
    end
  end

  def equal(params, modes)
    pos = store_index(params[2], modes[2])
    if number(params[0], modes[0]) == number(params[1], modes[1])
      code[pos] = 1
    else
      code[pos] = 0
    end
  end

  def adjust_relative_base(params, modes)
    @relative_base += number(params[0], modes[0])
  end

  def number(input, mode)
    method(mode).call(input)
  end

  def ops(code)
    opcode = code % 100
    mode1 = mode((code / 100) % 10)
    mode2 = mode((code / 1_000) % 10)
    mode3 = mode((code / 10_000) % 10)

    [opcode, mode1, mode2, mode3]
  end

  def mode(code)
    case code
    when 0 then :position
    when 1 then :value
    when 2 then :relative
    end
  end

  def position(index)
    code[index] || 0
  end

  def value(value)
    value
  end

  def relative(index)
    code[relative_base + index] || 0
  end

  def store_index(position, mode)
    case mode
    when :position then position
    when :relative then position + relative_base
    end
  end
end
