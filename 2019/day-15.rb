
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


def generate_map(map, get_oxygen = false)
  $oxygen_locations = []

  min_x = map.keys.min
  max_x = map.keys.max

  y_values = []
  
  for x in min_x..max_x do
    next if map[x].nil?
    y_values += map[x].keys
  end  
  
  min_y = y_values.min
  max_y = y_values.max

  x_values = []
  i = min_x
  while i <= max_x
    x_values << i
    i += 1
  end
  
  y_values = []
  j = min_y
  while j <= max_y
    y_values << j
    j += 1
  end

  x_values.each do | x |
    y_values.each do | y |
      if map[x].nil? or map[x][y].nil?
        map[x][y] = '?'
      end
      if get_oxygen and map[x][y] == 'O'
        $oxygen_locations << [x,y]
      end
    end
  end

  return map
end

def display_map(map, current_x=nil, current_y=nil)
  map = generate_map(map)

  map.keys.sort.each do | x |
    map[x].keys.sort.each do | y |
      if x == 0 and y == 0
        print "X"
      elsif current_x and current_y and x == current_x and y == current_y
        print "D"
      else
        if map[x][y] == '$' or map[x][y] == '+'
          print '.'
        else
          print map[x][y]
        end
      end
    end
    puts ''
  end
end

$movement = 0

def fully_mapped(map)
  unknowns = 0
  unreachable = 0
  map.keys.each do | x |
    map[x].keys.each do | y |
      if map[x][y] == '?'
        unknowns += 1
        if (map[x-1].nil? or map[x-1][y] == '#' or map[x-1][y].nil?) and
          (map[x+1].nil? or map[x+1][y] == '#' or map[x+1][y].nil?) and
          (map[x][y-1] == '#' or map[x][y-1].nil?) and
          (map[x][y+1] == '#' or map[x][y+1].nil?)
          unreachable += 1
        end
      end
    end
  end
  unknowns -= unreachable
  return unknowns == 0
end

def get_next_input(next_input)
  if $unvisited_directions.length > 0
    return $unvisited_directions.shift          
  elsif $more_ideal_directions.length > 0
    return $more_ideal_directions.shift
  else
    return $input_path[next_input]
  end
end

def intcode_computer(part_two = false)
  i = 0
  relative_base = 0

  $input_path = {1=>4, 2=>3, 3=>1, 4=>2}
  next_input = 1

  map = {}
  x = 0
  y = 0
  map[x] = {}
  map[x][y] = '.'

  input = nil

  oxygen_found = false
  
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
      previous_input = input || 0
      tries = []

      symbols_to_avoid = ['#', '$', '+']
      neutral_symbols  = []

      turning_around = false
      
      $unvisited_directions = []
      $more_ideal_directions = []
      
      if part_two
        unknown_symbols = ['?']
        $unvisited_directions << 1 if map[x+1].nil? or map[x+1][y].nil? or unknown_symbols.include?(map[x+1][y]) 
        $unvisited_directions << 4 if map[x].nil? or map[x][y+1].nil? or unknown_symbols.include?(map[x][y+1])
        $unvisited_directions << 2 if map[x-1].nil? or map[x-1][y] or unknown_symbols.include?(map[x-1][y])
        $unvisited_directions << 3 if map[x].nil? or map[x][y-1]  or unknown_symbols.include?(map[x][y-1])

        neutral_symbols << symbols_to_avoid.pop 
        $more_ideal_directions << 1 if map[x+1] and !neutral_symbols.include?(map[x+1][y]) and !$unvisited_directions.include?(1)
        $more_ideal_directions << 4 if map[x] and !neutral_symbols.include?(map[x][y+1]) and !$unvisited_directions.include?(4)
        $more_ideal_directions << 2 if map[x-1] and !neutral_symbols.include?(map[x-1][y]) and !$unvisited_directions.include?(2)
        $more_ideal_directions << 3 if map[x] and !neutral_symbols.include?(map[x][y-1]) and !$unvisited_directions.include?(3)
      end

      next_input = $more_ideal_directions.shift if $more_ideal_directions.length > 0
      next_input = $unvisited_directions.shift if $unvisited_directions.length > 0
      
      while true
        if tries.length == 3
          # puts "SURROUNDED BY WALLS"
          map[x][y] = "$"
        end

        case next_input
        when 1 # north
          if previous_input == 2
            if tries.length < 3
              next_input = get_next_input(next_input)
            else
              turning_around = true
              break
            end
          else
            if tries.include?(next_input)
              next_input = get_next_input(next_input)
            elsif map[x] and symbols_to_avoid.include?(map[x][y+1])
              tries << next_input
              next_input = get_next_input(next_input)
            else
              break
            end
          end
        when 2 # south
          if previous_input == 1
            if tries.length < 3
              next_input = get_next_input(next_input)
            else
              turning_around = true
              break
            end
          else
            if tries.include?(next_input)
              next_input = get_next_input(next_input)
            elsif map[x] and symbols_to_avoid.include?(map[x][y-1])
              tries << next_input
              next_input = get_next_input(next_input)
            else
              break
            end
          end
        when 3 # west
          if previous_input == 4
            if tries.length < 3
              next_input = get_next_input(next_input)
            else
              turning_around = true
              break
            end
          else
            if tries.include?(next_input)
              next_input = get_next_input(next_input)
            elsif map[x-1] and symbols_to_avoid.include?(map[x-1][y])
              tries << next_input
              next_input = get_next_input(next_input)
            else
              break
            end
          end
        when 4 # east
          if previous_input == 3
            if tries.length < 3
              next_input = get_next_input(next_input)
            else
              turning_around = true
              break
            end
          else
            if tries.include?(next_input)
              next_input = get_next_input(next_input)
            elsif map[x+1] and symbols_to_avoid.include?(map[x+1][y])
              tries << next_input
              next_input = get_next_input(next_input)
            else
              break
            end
          end
        end
      end

      input = next_input
      position = get_position_by_mode(mode1, i, 1, relative_base)
      $intcode[position] = input

      case input
      when 1
        #  print "NORTH: "
        y += 1
      when 2
        # print "SOUTH: "
	y -= 1
      when 3
        # print "WEST: "
        x -= 1
      when 4
        # print "EAST: "
        x += 1
      end
      
      i += 2
    when 4 # output 
      output = get_integer_by_mode(mode1, i, 1, relative_base)
      map[x] = {} if map[x].nil?

      case output
      when 0
        map[x][y] = '#'
        # puts "HIT A WALL"

        case input
        when 1
          y -= 1
        when 2
          y += 1
        when 3
          x += 1
        when 4
          x -= 1
        end
        next_input = $input_path[next_input]
        
      when 1
        map[x][y] = "."
        # puts "MOVED"
        $movement += 1
        next_input = part_two ? 1 : input
        # close off dead ends
        if turning_around
          # puts "TURNING AROUND"
          map[x][y] = "+"
        end
        $movement += 1
        
      when 2
        map[x][y] = "O"
        # puts "OXYGEN SYSTEM FOUND!"
        return [map, x, y] if !part_two
        oxygen_found = true
        oxygen_x, oxygen_y = [x,y]
      end

      map = generate_map(map) if part_two
      return [map, oxygen_x, oxygen_y] if part_two and oxygen_found and fully_mapped(map)

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

def traverse_map(map, x, y, final_x, final_y)
  previous_step = $path_taken.last if $steps > 0
  $path_taken << [x,y]
  
  return if x == final_x and y == final_y

  symbols = ['#', '?']  
  possible_directions = []
  # north
  possible_directions << [x+1, y] if map[x+1] and !symbols.include?(map[x+1][y])
  # south
  possible_directions << [x-1, y] if map[x-1] and !symbols.include?(map[x-1][y])
  # west
  possible_directions << [x, y-1] if map[x] and !symbols.include?(map[x][y-1])
  # east
  possible_directions << [x, y+1] if map[x] and !symbols.include?(map[x][y+1])
  
  #remove going backwards, since we have code to backtrack
  if previous_step
    index = possible_directions.index(previous_step)
    possible_directions.delete_at(index) if index
  end

  # there's a dead-end in that direction
  if possible_directions.length > 1
    indices = []
    for i in 0..possible_directions.length-1 do
      if map[possible_directions[i][0]][possible_directions[i][1]] == '+'
        indices << i
      end
    end
    indices.each do | index |
      possible_directions.delete_at(index)
    end
  end
  
  if possible_directions.length > 1
    if possible_directions.include?([final_x, final_y])
      x,y = possible_directions.index([final_x, final_y])
    else
      x,y = possible_directions.shift
      $back_tracking << [possible_directions, $steps]
    end
  elsif possible_directions.length == 1
    # move forward
    x,y = possible_directions[0]
  else # length == 0
     # need to backtrack
    possible_directions, steps = $back_tracking.pop
    $steps = steps
    x,y = possible_directions.shift
    $back_tracking << [possible_directions, $steps] if possible_directions.length > 0
  end

  $steps += 1
  traverse_map(map,x,y, final_x, final_y)
end

def traverse_oxygen_map(map, x, y, hash = nil)
  hash = {} if hash.nil?
  
  map[x][y] = 'O'

  symbols = ['#', 'O']
  possible_directions = []
  possible_directions << [x+1, y] if map[x+1] and !symbols.include?(map[x+1][y])
  possible_directions << [x-1, y] if map[x-1] and !symbols.include?(map[x-1][y])
  possible_directions << [x, y-1] if map[x] and !symbols.include?(map[x][y-1])
  possible_directions << [x, y+1] if map[x] and !symbols.include?(map[x][y+1])

  return {} if possible_directions.length == 0
  
  possible_directions.each do | x2,y2 |
    hash["#{x},#{y}"] = {} if hash["#{x},#{y}"].nil?
    hash["#{x},#{y}"] = traverse_oxygen_map(map,x2,y2,hash["#{x},#{y}"])
  end

  return hash
end

def get_longest_path(hash, path_length = nil)
  path_length = 0 if path_length.nil?
  if hash == {}
    if $longest_path_seen < path_length
      $longest_path_seen = path_length
      path_length = 0
    end
    return
  end
  path_length += 1
  hash.each do | key, value |
    get_longest_path(value, path_length)
  end
end





filename = "day-15-input.txt"

$intcode = File.read(filename).chomp.split(',').map(&:to_i)
intcode = $intcode.dup

map, x, y = intcode_computer()
#display_map(map, x, y)
generate_map(map)

$path_taken = []
$back_tracking = []

$steps = 0
traverse_map(map,0,0,x,y)
puts "PART ONE: #{$steps}"

$intcode = intcode

map, x, y = intcode_computer(true)
#puts "#{x}, #{y}"

# map_string = "?###?###?###############?#####?###?#####?|#...#...#...............#.....#...#.....#|#.#.#.#.#.#####.#########.#.###.#.#.###.#|#.#...#.#.#...#...#.....#.#...#.#...#...#|#.#####.#.#.#####.#.###.#.###.#.#####.##?|#.....#.#.#.#.....#...#.....#.......#...#|?######.#.#.#.###.#.#######.#######.###.#|#.....#.#.#.#...#.#.#.....#.#.....#...#.#|#.###.#.#.#.###.###.#.###.###.###.#####.#|#...#...#.#...#.#...#.#.#.#...#.#.......#|?##.#.###.#.###.#.###.#.#.#.###.#######.#|#...#.#...#...#.#...#.#...#...#.........#|#.#.###.#####.#.###.#.###.###.#.########?|#.#.#...#.....#...#.#...#.#...#...#.....#|#.###.#####.###.#.#.###.#.#.#####.#####.#|#...........#...#.#.#...#...#.........#.#|?##########.#.#####.#.###############.#.#|#.....#.....#.....#.#.............#...#.#|#.###.#.#########.#.#############.#.###.#|#.#.#.#.........#.....#.......#.#.#...#.#|#.#.#.#######.#######.#.#####.#.#.###.#.#|#...#.....#...#.....#...#...#...#.#.#...#|?##.#####.#####.#########.#.#####.#.###.#|#.#.....#.......#.....#...#.......#...#.#|#.#####.#########.###.#.###########.#.#.#|#.....#.#.........#.#...#...#.....#.#.#.#|#.#.###.#.###.#####.####?##.#.#.#.#.#.#.#|#.#.....#...#.#.........#...#.#.#.#.#.#.#|#.######?####.#.###.###.#.#.#.#.#.#.#.#.#|#.......#.....#.#...#.....#.#.#.#...#.#.#|?######.#.#####.#.###########.#.####?##.#|#.....#...#.....#.....#.......#.#...#...#|#.###.#####.####?####.#.#######.#.#.#.##?|#.#.#.....#.....#...#.......#...#.#...#.#|#.#.###.#######.#.#.#########.#.#.#####.#|#...#O#.......#...#...#...#...#.#.....#.#|?##.#.#####.#########.#.#.#.#########.#.#|#...#.....#.#.......#.#.#...#.......#.#.#|#.#####.#.#.#.#.#####.#.#####.#####.#.#.#|#.......#.#...#.......#...........#.....#|?#######?#?###?#######?###########?#####?|"

# map_array = map_string.split('|')

# map = {}

# for i in 0..map_array.length-1 do
#   map[i] = {}
#   inner_map_array = map_array[i].split('')
#   for j in 0..inner_map_array.length-1 do
#     map[i][j] = inner_map_array[j]
#     if map[i][j] == 'O'
#       x,y = [i,j]
#     end
#   end
# end

map_hash = traverse_oxygen_map(map, x, y)

$longest_path_seen = 0

get_longest_path(map_hash)
puts "PART TWO: #{$longest_path_seen}"
