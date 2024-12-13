
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
  while true do
    thruster = $thrusters.shift
    
    $intcode = $intcodes[thruster]
    i = $index[thruster]

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
#        puts "ADDING #{integer1} + #{integer2} and replacing #{position} with #{sum}"
        i += 4
      when 2
        integer1 = get_integer_by_mode(mode1, i, 1)
        integer2 = get_integer_by_mode(mode2, i, 2)
        position = $intcode[i+3]
        product = integer1 * integer2
        $intcode[position] = product
#        puts "MULTIPLYING #{integer1} * #{integer2} and replacing #{position} with #{product}"
        i += 4
      when 3 
        $input_count += 1
        if $input_count % 2 == 1 and $input_count <= 10
          input = $phase_settings.shift
        else
          input = $input_signal
        end
#        puts "INPUT: #{input}"
        position = $intcode[i+1]
        $intcode[position] = input
        i += 2
      when 4
        position = $intcode[i+1]
        output = mode1 == 0 ? $intcode[position] : position
#        puts "OUTPUT: #{output}"
        $input_signal = output
        i +=2
        $index[thruster] = i
        $thrusters << thruster
        break
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
#        puts "HALTING at position #{i} on thruster #{thruster}"
        return
      else
        puts "ERROR at position #{i}"
        return
      end
    end
  end
end
  
$intcode_original = File.read("day-7-input.txt").chomp.split(',').map(&:to_i)

#$intcode_original = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]

#$intcode_original = [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]

#available_phase_settings = [0, 1, 2, 3, 4]
available_phase_settings = [5, 6, 7, 8, 9]
possible_permutations = available_phase_settings.permutation.to_a

$outputs = []
$full_outputs = []

def init_arrays
  $index = {}
  $index['A'] = 0
  $index['B'] = 0
  $index['C'] = 0
  $index['D'] = 0
  $index['E'] = 0 

  $intcodes = {}
  $intcodes['A'] = $intcode_original.dup
  $intcodes['B'] = $intcode_original.dup
  $intcodes['C'] = $intcode_original.dup
  $intcodes['D'] = $intcode_original.dup
  $intcodes['E'] = $intcode_original.dup

  $thrusters = %w{A B C D E}

  $input_count = 0
end

possible_permutations.each do | phase_settings |
  $input_signal = 0

  init_arrays()

  $phase_settings = phase_settings.dup
  
  intcode_computer()

  $outputs << $input_signal
end

highest_signal = $outputs.max

puts highest_signal
