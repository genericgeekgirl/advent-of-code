def run_program
  i = 0

  while i <= $intcode.length
    opcode = $intcode[i]
    case opcode
    when 1
      integer1 = $intcode[$intcode[i+1]]
      integer2 = $intcode[$intcode[i+2]]
      position = $intcode[i+3]
      sum = integer1 + integer2
      $intcode[position] = sum
      puts "ADDING #{integer1} + #{integer2} and replacing #{position} with #{sum}"
      i += 4
    when 2
      integer1 = $intcode[$intcode[i+1]]
      integer2 = $intcode[$intcode[i+2]]
      position = $intcode[i+3]
      product = integer1 * integer2
      $intcode[position] = product
      puts "MULTIPLYING #{integer1} * #{integer2} and replacing #{position} with #{product}"
      i += 4
    when 99
      puts "BREAKING at position #{i}"
      break
    else
      puts "ERROR at position #{i}"
      break
    end
  end

  return $intcode[0]
end

desired_solution = 19690720

for noun in 1..99 do
  for verb in 1..99 do

    $intcode = File.read("day-2-input.txt").chomp.split(',').map(&:to_i)
    
    $intcode[1] = noun
    $intcode[2] = verb

    position_0 = run_program()

    if position_0 == desired_solution
      solution = 100 * noun + verb
      puts solution
      exit!
    end
  end
end

