
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
      input = $input.shift
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
      puts "ERROR"
      break
    end
  end
end

def generate_map(coordinates)
  map = []
  for j in 0..coordinates.length-1 do
    next if coordinates[j].nil?
    map[j] = []
    for i in 0..coordinates[j].length-1 do
      next if coordinates[j][i].nil?
      value = coordinates[j][i]
      map[j][i] = value == 1 ? '#' : '.'
    end
  end
  
  return map
end

def check_size(coordinates, size)
  for j in (0..coordinates.length-1).to_a.reverse do
    break if coordinates[j-size].nil?
    for i in (0..coordinates[j].length-1).to_a.reverse do
      value = coordinates[j][i]
      next if value == 0
      break if coordinates[j][i-size].nil?
      value_at_width = coordinates[j][i-(size-1)]
      next if value_at_width == 0
      value_at_height = coordinates[j-(size-1)][i]
      if value_at_height == 1
        return [i-(size-1), j-(size-1)]
      end
    end
  end
  
  return [nil, nil]
end

intcode = File.read("day-19-input.txt").chomp.split(',').map(&:to_i)

$input = []
$output_array = []
coordinates = []

for y in 0..49 do
  coordinates[y] = []
  for x in 0..49 do 
    $input += [x,y]
    $intcode = intcode.dup
    intcode_computer()
    coordinates[y][x] = $output_array.last
  end
end

affected = $output_array.count(1)
puts "PART 1: #{affected}"

$input = []
$output_array = []
coordinates = []

size = 100

y = 0
x_start = 0
y_count = 0
while true
  coordinates[y] = []
  x = x_start
  x = 0
  x_count = 0
  start = false
  while true
    $input += [x,y]
    $intcode = intcode.dup
    intcode_computer()
    value = $output_array.last
    coordinates[y][x] = value
    if value == 1 and !start
      x_start = x
      start = true
    end
    break if $output_array.last(2) == [1,0]
    break if x > 10 and y < 10 and !start
    break if x_count > size * size
    x_count += 1 if start
    x += 1
  end
  if x_count >= size
    y_count += 1
  end
  x1, y1 = check_size(coordinates, size) if y_count >= size
  break if !x1.nil? and !y1.nil?
  y += 1
end

solution = x1*10000 + y1
puts "PART 2: #{solution}"
