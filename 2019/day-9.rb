
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

$output_array = []

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
      puts "ADDING #{integer1} + #{integer2} and replacing position #{position} with #{sum}"      
      i += 4
    when 2 # multiplication
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      product = integer1 * integer2
      $intcode[position] = product
      puts "MULTIPLYING #{integer1} * #{integer2} and replacing position #{position} with #{product}"
      i += 4
    when 3 # input
      print "INPUT: "
      input = gets.chomp.to_i
      position = get_position_by_mode(mode1, i, 1, relative_base)
      puts "SAVING input #{input} to position #{position}"
      $intcode[position] = input
      i += 2
    when 4 # output 
      output = get_integer_by_mode(mode1, i, 1, relative_base)
      puts "OUTPUT: #{output}"
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
      puts "COMPARING #{integer1} < #{integer2} and saving #{value} to position #{$intcode[position]}"
      i += 4
    when 8 # equals
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      value = integer1 == integer2 ? 1 : 0
      $intcode[position] = value
      puts "COMPARING #{integer1} == #{integer2} and saving #{value} to position #{$intcode[position]}"
      i += 4
    when 9 # update relative base
      adjustment = get_integer_by_mode(mode1, i, 1, relative_base)
      puts "UPDATING relative base: ADDING #{relative_base} + #{adjustment}"
      relative_base += adjustment
      i += 2
    when 99 # HALT
      puts "BREAKING at position #{i}"
      break
    else
      puts "ERROR at position #{i}"
      break
    end
  end
end

$intcode = File.read("day-9-input.txt").chomp.split(',').map(&:to_i)

#$intcode = [1102,34915192,34915192,7,4,7,99,0]
#$intcode = [104,1125899906842624,99]
#$intcode = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]

intcode_computer()

puts $output_array.join(",")
