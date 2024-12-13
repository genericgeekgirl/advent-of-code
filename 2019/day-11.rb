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

$map = {}

$row = 0
$column = 0

def paint(color)
  $map["#{$row},#{$column}"] = color
end

def move(direction_facing)
  case direction_facing
  when 0
    $row -= 1
  when 90
    $column += 1
  when 180
    $row += 1
  when 270
    $column -= 1
  end
end

def intcode_computer
  i = 0
  relative_base = 0
  output_count = 0
  color = 0
  direction_facing = 0
  
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
      if $map.length == 0
        input = $initial_input
      else
        input = $map["#{$row},#{$column}"] || 0
      end
        position = get_position_by_mode(mode1, i, 1, relative_base)
      $intcode[position] = input
      i += 2
    when 4 # output
      output_count += 1
      output = get_integer_by_mode(mode1, i, 1, relative_base)
      if output_count % 2 == 1
        color = output
        paint(color)
      else
        turn_direction = output
        direction_facing += turn_direction == 0 ? -90 : 90
        direction_facing = 0 if direction_facing == 360
        direction_facing = 270 if direction_facing == -90
        move(direction_facing)
      end
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

$intcode = File.read("day-11-input.txt").chomp.split(',').map(&:to_i)

$initial_input = 1

intcode_computer()

pretty_map = {}

rows = []
columns = []

$map.each do | key, value |
  row, column = key.split(',').map(&:to_i)
  rows << row
  columns << column
  pretty_map[row] = {} if pretty_map[row].nil?
  pretty_map[row][column] = value == 0 ? '.' : '#'
end

height = rows.max
width = columns.max

for row in 0..height do
  for column in 0..width do
    if pretty_map[row][column].nil?
      pretty_map[row][column] = (row == 0 and column == 0) ? '#' : '.'
    end
  end
end

pretty_map.keys.sort.each do | row |
 pretty_map[row].keys.sort.each do | column |
   print pretty_map[row][column]
 end
 puts ""
end


