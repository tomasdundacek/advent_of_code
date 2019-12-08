class IntCode
  OPCODES = [nil, :add, :multiply, :input, :output, :jump_if_true, :jump_if_false, :less_than, :equal].freeze
  LENGTHS = [nil, 4, 4, 2, 2, 3, 3, 4, 4].freeze

  attr_accessor :code, :debug, :halted, :feedback_mode, :inputs, :pos, :pos_modified

  def initialize(code = [], inputs = [], feedback_mode: false, debug: false)
    @code = code
    @inputs = inputs
    @pos = 0
    @pos_modified = false
    @debug = debug
    @feedback_mode = feedback_mode
    @halted = false
  end

  def run
    opcode, *modes = ops(code[pos])

    while opcode != 99
      params = code[(pos + 1)..(pos + LENGTHS[opcode] - 1)]

      break if opcode == 3 && inputs.empty?

      if debug
        puts code.inspect
        puts "Pos: #{pos}"
        puts "Opcode: #{opcode}"
        puts "Len: #{LENGTHS[opcode]}"
        puts "Params: #{params}"
        puts "Modes: #{modes}"
        puts "==="
      end

      method(OPCODES[opcode]).call(params, modes)

      @pos += LENGTHS[opcode] unless pos_modified

      break if opcode == 4

      opcode, *modes = ops(code[pos])
      @pos_modified = false
    end

    @halted = true if opcode == 99
    [4, 99].include?(opcode) ? @last_output : nil
  end

  private

  def add(params, modes)
    code[params[2]] = number(params[0], modes[0]) + number(params[1], modes[1])
  end

  def multiply(params, modes)
    code[params[2]] = number(params[0], modes[0]) * number(params[1], modes[1])
  end

  def input(params, _modes)
    code[params[0]] = inputs.shift
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
    if number(params[0], modes[0]) < number(params[1], modes[1])
      code[params[2]] = 1
    else
      code[params[2]] = 0
    end
  end

  def equal(params, modes)
    if number(params[0], modes[0]) == number(params[1], modes[1])
      code[params[2]] = 1
    else
      code[params[2]] = 0
    end
  end

  def number(input, mode)
    method(mode).call(input)
  end

  def ops(code)
    opcode = code % 100
    mode1 = (code / 100)    % 10 == 0 ? :position : :value
    mode2 = (code / 10_00)  % 10 == 0 ? :position : :value
    mode3 = (code / 10_000) % 10 == 0 ? :position : :value

    [opcode, mode1, mode2, mode3]
  end

  def position(index)
    code[index]
  end

  def value(value)
    value
  end
end
