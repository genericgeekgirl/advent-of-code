
def get_integer_by_mode(mode, i, offset, relative_base)
  case mode
  when 0 # positional mode
    integer = $intcode[$intcode[i+offset]] || 0
  when 1 # immediate mode
    integer = $intcode[i+offset] || 0
  when 2 # relative mode
    integer = $intcode[$intcode[i+offset] + relative_base] || 0
  end
  return integer
end

def get_position_by_mode(mode, i, offset, relative_base)
  case mode
  when 0 # positional mode
    position = $intcode[i+offset]
  when 1 # immediate mode
    puts "ERROR"
  when 2 # relative mode
    position = $intcode[i+offset] + relative_base
  end
  return position
end

def intcode_computer
  i = 0
  relative_base = 0
  
  while i <= $intcode.length
    opcode = $intcode[i]

    modes = []
    
    if opcode.abs.to_s.length > 2
      opcode = opcode.to_s.reverse
      modes = opcode[2..-1].reverse.split('').map(&:to_i)
      opcode = opcode[0..1].reverse.to_i
    end

    mode1 = modes.length > 0 ? modes.pop : 0
    mode2 = modes.length > 0 ? modes.pop : 0
    mode3 = modes.length > 0 ? modes.pop : 0

    case opcode
    when 1 # addition
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      sum = integer1 + integer2
      $intcode[position] = sum
      i += 4
    when 2 # multiplication
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      product = integer1 * integer2
      $intcode[position] = product
      i += 4
    when 3 # input
      if $instructions.length > 0
        input = $instructions.shift
      end
      position = get_position_by_mode(mode1, i, 1, relative_base)
      $intcode[position] = input
      i += 2
    when 4 # output 
      output = get_integer_by_mode(mode1, i, 1, relative_base)
      $output_array << output
      i += 2
    when 5 # jump-if-true
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      i = (integer1 != 0) ? integer2 : i+3
    when 6 # jump-if-false
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      i = (integer1 == 0) ? integer2 : i+3
    when 7 # less than
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      value = integer1 < integer2 ? 1 : 0
      $intcode[position] = value
      i += 4
    when 8 # equals
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      value = integer1 == integer2 ? 1 : 0
      $intcode[position] = value
      i += 4
    when 9 # update relative base
      adjustment = get_integer_by_mode(mode1, i, 1, relative_base)
      relative_base += adjustment
      i += 2
    when 99 # HALT
      break
    else
      puts "ERROR at position #{i}"
      break
    end
  end
end

def to_ascii(instructions)
  ascii = []

  instructions.each do | instruction |
    ascii_instruction = []

    instruction.split('').each do | char |
      ascii_instruction << char.ord
    end
    
    ascii_instruction << "\n".ord
    ascii << ascii_instruction
  end

  return ascii.flatten
end

def process_output
  map_characters = ['@'.ord, '#'.ord, '.'.ord, "\n".ord]
  newline = "\n".ord
  
  if map_characters.include?($output_array.last)
    map = $output_array.join('-').split("-#{newline}-")
    map.each do | line |
      characters = line.split('-')
      characters.each do | char |
        print char.to_i.chr
      end
      puts ""
    end
    $ouput_array = []
    return nil
  else
    return $output_array.last
  end
end

instructions = [
  "NOT A J",
  "NOT B T",
  "NOT C T",
  "AND D T",
  "OR T J",

  "WALK"
]

$instructions = to_ascii(instructions)
$output_array = []

$intcode = File.read("day-21-input.txt").chomp.split(',').map(&:to_i)
intcode_computer()

damage = process_output
puts "PART 1: #{damage}" if damage

instructions = [
  "NOT A J",

  "NOT C T",
  "AND B T",
  "AND D T",
  "AND H T",
  "OR T J",
  
  "NOT B T",
  "AND D T",
  "AND H T",
  "OR T J",
  
  "RUN"
]

$instructions = to_ascii(instructions)
$output_array = []

$intcode = File.read("day-21-input.txt").chomp.split(',').map(&:to_i)
intcode_computer()

damage = process_output
puts "PART 2: #{damage}" if damage
