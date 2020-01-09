
def get_map(filename)
  map = []
  File.open(filename).each do |line|
    map << line.chomp.split('')
  end
  return map
end

def find_doors(map)
  alphabet = [*"A".."Z"].to_a
  path = '.'
  
  doors = {}
  letters_seen = []
  
  for y in 0..map.length-1 do
    # scan row for letters, move on if there are none
    next unless (map[y] & alphabet).length > 0
    for x in 0..map[0].length-1 do
      letter_1 = nil
      letter_2 = nil
      coordinates = nil
      # if we find a letter,
      if alphabet.include?(map[y][x])
        letter_1 = map[y][x]
        # check character to right
        if alphabet.include?(map[y][x+1])
          letter_2 = map[y][x+1]
          # is the door to the right or left?
          if map[y][x+2] and map[y][x+2] == path
            coordinates = [x+2, y]
          elsif map[y][x-1] == path
            coordinates = [x-1, y]
          end
        # then check character to bottom
        elsif map[y+1] and alphabet.include?(map[y+1][x])
          letter_2 = map[y+1][x]
          # is the door below or above?
          if map[y+2] and map[y+2][x] == path
            coordinates = [x, y+2]
          elsif map[y-1][x] == path
            coordinates = [x, y-1]
          end
        end
        if letter_2 and coordinates
          letters_seen += [letter_1, letter_2]
          door = [letter_1, letter_2].join('')
          doors[door] = [] if doors[door].nil?
          doors[door] << coordinates
        end
      end
    end
  end

  return doors, letters_seen.uniq
end

def find_possible_directions(map,x,y,symbols, previous_steps, backtracking,branches_taken)
  possible_directions = []
  # exclude walls and doors
  possible_directions << [x, y-1] if !symbols.include?(map[y-1][x])
  possible_directions << [x+1, y] if !symbols.include?(map[y][x+1])
  possible_directions << [x, y+1] if !symbols.include?(map[y+1][x])
  possible_directions << [x-1, y] if !symbols.include?(map[y][x-1])

#  possible_directions = possible_directions.shuffle
  
  # now check whether we're standing on a portal and add other end to directions
  if $portals_by_map.include?([x,y])
    portal = $portals_by_map[[x,y]]
    doors = $portals_by_name[portal].dup
    doors.delete([x,y])
    # try the portal first (unless we just came through it)
    possible_directions.unshift(doors[0]) unless previous_steps.last == doors[0]
  end

  # avoid walking in loops
  previously_seen_junctions = []

  backtracking.each do | directions, steps |
    previously_seen_junctions = directions & possible_directions 
    possible_directions -= previously_seen_junctions
  end

  branches_taken.each do | directions |
    previously_seen_junctions = directions & possible_directions 
    possible_directions -= previously_seen_junctions
  end

  #remove going backwards, since we have code to backtrack
  if previous_steps
    previously_seen_path = previous_steps & possible_directions 
    possible_directions -= previously_seen_path
  end

  return possible_directions
end

def traverse_map(map, x, y, final_x, final_y, steps = 0, previous_steps = [], backtracking = [], branches_taken = [])
  $paths_found << steps if [x,y] == [final_x,final_y]
    
  if $paths_found.length > 0 and $exit
    return
  end
  
  symbols = ['#'] + $letters
  possible_directions = find_possible_directions(map,x,y,symbols,previous_steps,backtracking,branches_taken)
  previous_steps << [x,y]
  
  if possible_directions.length > 1 # pick one 
    if possible_directions.include?([final_x, final_y]) # voila
      x,y = [final_x, final_y]
    else
      if (possible_directions & $portals_by_map.keys).length > 0
        portal = possible_directions & $portals_by_map.keys
        x,y = portal[0]
        possible_directions.delete(portal[0])
      else
        x,y = possible_directions.shift # save other directions
      end
      backtracking << [possible_directions, steps]
      branches_taken << [x,y]
    end
  elsif possible_directions.length == 1  # move forward
    x,y = possible_directions[0]
  else # we've hit a dead end
    if backtracking.length > 0 # able to backtrack
      possible_directions, new_steps = backtracking.pop
      difference = steps - new_steps
      steps = new_steps
      x,y = possible_directions.shift
      branches_taken << [x,y]
      backtracking << [possible_directions, steps] if possible_directions.length > 0
      previous_steps.pop(difference)
    else
      return # we've found all the paths
    end
  end
  
  steps += 1
  traverse_map(map, x, y, final_x, final_y, steps, previous_steps, backtracking, branches_taken)
end

def find_portals(doors)
  doors.delete('AA')
  doors.delete('ZZ')
  portals_by_name = doors

  portals_by_map = {}
  doors.each do | portal, coordinates |
    coordinates.each do | portal_end |
      portals_by_map[portal_end] = portal
    end
  end
  
  return portals_by_name, portals_by_map
end

#filename = 'day-20-input.txt' # 714
#filename = 'day-20-input-3.txt' # only for part two
#filename = 'day-20-input-2.txt' # 58 # only for part one
filename = 'day-20-input-1.txt' # 23

map = get_map(filename)
doors, $letters = find_doors(map)
start_x, start_y = doors['AA'][0]
final_x, final_y = doors['ZZ'][0]
$portals_by_name, $portals_by_map = find_portals(doors)

$paths_found = []
#$exit = true # I can't figure out how to get past the "stack level too deep" error
traverse_map(map, start_x, start_y, final_x, final_y)
steps = $paths_found.min

puts "PART 1: #{steps}"

