
def get_integer_by_mode(mode, i, offset)
  integer = nil
  case mode
  when 0
    integer = $intcode[$intcode[i+offset]]
  when 1
    integer = $intcode[i+offset]
  end
  return integer
end

def intcode_computer
  i = 0

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
    when 1
      integer1 = get_integer_by_mode(mode1, i, 1)
      integer2 = get_integer_by_mode(mode2, i, 2)
      position = $intcode[i+3]
      sum = integer1 + integer2
      $intcode[position] = sum
      puts "ADDING #{integer1} + #{integer2} and replacing #{position} with #{sum}"
      i += 4
    when 2
      integer1 = get_integer_by_mode(mode1, i, 1)
      integer2 = get_integer_by_mode(mode2, i, 2)
      position = $intcode[i+3]
      product = integer1 * integer2
      $intcode[position] = product
      puts "MULTIPLYING #{integer1} * #{integer2} and replacing #{position} with #{product}"
      i += 4
    when 3
      puts "INPUT: "
      input = gets.chomp.to_i
      position = $intcode[i+1]
      $intcode[position] = input
      i += 2
    when 4
      position = $intcode[i+1]
      output = mode1 == 0 ? $intcode[position] : position
      puts "OUTPUT: #{output}"
      i += 2
    when 5
      integer1 = get_integer_by_mode(mode1, i, 1)
      integer2 = get_integer_by_mode(mode2, i, 2)
      if integer1 != 0
        i = integer2
      else
        i += 3
      end
    when 6
      integer1 = get_integer_by_mode(mode1, i, 1)
      integer2 = get_integer_by_mode(mode2, i, 2)
      if integer1 == 0
        i = integer2
      else
        i += 3
      end      
    when 7 
      integer1 = get_integer_by_mode(mode1, i, 1)
      integer2 = get_integer_by_mode(mode2, i, 2)
      position = $intcode[i+3]
      $intcode[position] = integer1 < integer2 ? 1 : 0
      i += 4
    when 8
      integer1 = get_integer_by_mode(mode1, i, 1)
      integer2 = get_integer_by_mode(mode2, i, 2)
      position = $intcode[i+3]
      $intcode[position] = integer1 == integer2 ? 1 : 0
      i += 4
    when 99
      puts "BREAKING at position #{i}"
      break
    else
      puts "ERROR at position #{i}"
      break
    end
  end
end

$intcode = File.read("day-5-input.txt").chomp.split(',').map(&:to_i)

intcode_computer()
