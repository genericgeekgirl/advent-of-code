
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

def intcode_computer(part_two = false)
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
      if $input.length > 0
        input = $input.shift
      else
        puts "ERROR"
      end
      position = get_position_by_mode(mode1, i, 1, relative_base)
      $intcode[position] = input
      i += 2
    when 4 # output 
      output = get_integer_by_mode(mode1, i, 1, relative_base)
      $output_array << output if !part_two
      $dust = output
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

def generate_map
  x = 0
  y = 0

  map = []
  map[x] = []
  
  $output_array.each do | output |
    if output == 10
      x += 1
      y = 0
      map[x] = []
    else
      map[x][y] = output.chr
      y += 1
    end
  end
  
  return map
end

def print_map(map)
  map.each do | x |
    puts x.join('')
  end
end

def find_intersections(map)
  intersections = []
  for x in 0..map.length-1 do
    for y in 0..map[x].length-1 do
      if map[x][y] == '#' and check_four_directions(map, x, y)
        intersections << [x,y]
      end
    end
  end

  sum = intersections.map { |x,y| x*y }.reduce(:+)
  return sum
end
      
def check_four_directions(map, x, y)
  return false if x == 0 or x == map.length-1
  return false if y == 0 or y == map[x].length-1
  return true if map[x-1][y] == "#" and map[x+1][y] == "#" and
    map[x][y-1] == "#" and map[x][y+1] == "#"
  return false
end

def find_starting_point(map)
  cursor_symbols = %w{^ v < > X}
  for x in 0..map.length-1 do
    for y in 0..map[x].length-1 do
      if cursor_symbols.include?(map[x][y])
        return [x,y,map[x][y]]
      end
    end
  end
end

def check_direction(map,x,y,direction)
  case direction
  when '^'
    return (map[x-1] and map[x-1][y] == '#')
  when '>'
    return (map[x] and map[x][y+1] == '#')
  when 'v'
    return (map[x+1] and map[x+1][y] == '#')
  when '<'
    return (map[x] and map[x][y-1] == '#')
  end      
end

def move_direction(x,y,direction)
  case direction
  when '^'
    x -= 1
  when '>'
    y += 1
  when 'v'
    x += 1
  when '<'
    y -= 1
  end      

  return [x,y]
end
  
def get_route(map,x,y,direction)
  next_direction = {'^' => '>', '>' => 'v', 'v' => '<', '<' => '^'}
  opposite_direction = {'^' => 'v', '>' => '<', 'v' => '^', '<' => '>'}

  instructions = []
  forward_count = 0
  
  while true
    if check_direction(map,x,y,direction)
      forward_count += 1
      x,y = move_direction(x,y,direction)
    else
      instructions << forward_count if forward_count > 0
      forward_count = 0
      right = next_direction[direction]
      left = opposite_direction[right]
      if check_direction(map,x,y,right)
        instructions << 'R'
        direction = right
      elsif check_direction(map,x,y,left)
        instructions << 'L'
        direction = left
      else
        break # we've hit the end
      end
    end
  end
  
  return instructions
end

def to_ascii(instructions)
  instructions = instructions.split(',')
  ascii = []

  instructions.each do | command |
    ascii_string = []
    command.split('').each do | char |
      ascii_string << char.ord.to_s
    end
    ascii << ascii_string.join("-")
  end
  
  comma = ','.ord.to_s
  
  ascii = ascii.join("-#{comma}-").split('-').map(&:to_i) + ["\n".ord]

  return ascii
end

def find_patterns(instructions)
  patterns = []

  (4..10).step(2) do | length |
    i = 0
    while i <= instructions.length-length do
      pattern = instructions[i, length].dup
      if pattern.join('').length > 20 # two digit numbers are 4 characters
        i += 2
      else
        repeating = instructions.join(',').scan(pattern.join(',')).length
        if repeating > 1
          patterns << pattern
          i += length
        else
          i += 2
        end
      end
    end
  end

  letters = %w{A B C}
  combinations = patterns.combination(3).to_a
  subroutine_patterns = {}
  
  shortest_string = instructions.length
  subroutines_to_return = {}
  string_to_return = ''
  
  while combinations.length > 0
    combination = combinations.shift
    string = instructions.join(',')
    subroutines = letters.dup
    subroutine_patterns = {}

    combination.each do | pattern |
      pattern_string = pattern.join(',')
      if string.scan(pattern_string).length > 1
        subroutine = subroutines.shift
        subroutine_patterns[subroutine] = pattern.join(',')
        string.gsub! pattern_string, subroutine
      end
    end

    string_length = string.split(',').length

#    if subroutines.length == 0 and string_length <= 20
    if subroutines.length == 0 and string_length <= 20
      # string.split(',').uniq.sort != letters # this doesn't work?
      if string_length < shortest_string
        shortest_string = string_length
        subroutines_to_return = subroutine_patterns
        string_to_return = string
      end
    end
  end

  return [subroutines_to_return, string_to_return]
end

#########

$output_array = []

$intcode = File.read("day-17-input.txt").chomp.split(',').map(&:to_i)

intcode_computer()

map = generate_map
#print_map(map)
sum = find_intersections(map)
puts "PART 1: #{sum}"

$intcode = File.read("day-17-input.txt").chomp.split(',').map(&:to_i)
$intcode[0] = 2

x, y, direction = find_starting_point(map)
instructions = get_route(map,x,y,direction)

subroutines, instructions = find_patterns(instructions)

main_routine = to_ascii(instructions)
function_a = to_ascii(subroutines['A'])
function_b = to_ascii(subroutines['B'])
function_c = to_ascii(subroutines['C'])

video_feed = 'n'
video_feed = [video_feed.ord, "\n".ord]

$input = main_routine + function_a + function_b + function_c + video_feed

intcode_computer(true)

puts "PART 2: #{$dust}"
