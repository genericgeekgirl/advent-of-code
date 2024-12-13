
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
      inner = false
      # if we find a letter,
      if alphabet.include?(map[y][x])
        letter_1 = map[y][x]
        # check character to right
        if alphabet.include?(map[y][x+1])
          letter_2 = map[y][x+1]
          # is the door to the right or left?
          if map[y][x+2] and map[y][x+2] == path
            inner = x!=0 and !map[y][x-1].nil?
            coordinates = [x+2, y]            
          elsif map[y][x-1] == path
            inner = !map[y][x+2].nil?
            coordinates = [x-1, y]
          end
        # then check character to bottom
        elsif map[y+1] and alphabet.include?(map[y+1][x])
          letter_2 = map[y+1][x]
          # is the door below or above?
          if map[y+2] and map[y+2][x] == path
            inner = y!=0 and !map[y-1].nil?
            coordinates = [x, y+2]
          elsif map[y-1][x] == path
            inner = !map[y+2].nil?
            coordinates = [x, y-1]
          end
        end
        if letter_2 and coordinates
          letters_seen += [letter_1, letter_2]
          door = [letter_1, letter_2].join('')
          doors[door] = {} if doors[door].nil?
          if inner
            doors[door]["inner"] = coordinates
          else
            doors[door]["outer"] = coordinates
          end
        end
      end
    end
  end

  return doors, letters_seen.uniq
end

def find_possible_directions(map,x,y, level, symbols, previous_steps, backtracking,branches_taken,final_x,final_y,final_level,portals_used)
  possible_directions = []
  # exclude walls and doors
  possible_directions << [x, y-1, level] if !symbols.include?(map[y-1][x])
  possible_directions << [x+1, y, level] if !symbols.include?(map[y][x+1])
  possible_directions << [x, y+1, level] if !symbols.include?(map[y+1][x])
  possible_directions << [x-1, y, level] if !symbols.include?(map[y][x-1])

  # now check whether we're standing on a portal and add other end to directions
  if $portals_by_map.include?([x,y])

    add_portal = true
    
    portal = $portals_by_map[[x,y]]
    doors = $portals_by_name[portal].dup
    location = doors.key([x,y])    
    coordinates = doors.values
    coordinates.delete([x,y])

    next_level = level
    last_level = level
    if $part_two
      next_level = location == "inner" ? level+1 : level-1
      last_level = location == "outer" ? level+1 : level-1
    end
    
    next_x,next_y = coordinates[0]

    # don't go back through the portal we just came from
    if previous_steps.last == [next_x,next_y,last_level]
      add_portal = false
    end

    # identify a pattern of portal use and squash it
    # TODO: Having trouble with this
    
    # outer portals are locked on the final level
    if location == "outer" and level == final_level
      add_portal = false
    end

    if add_portal
      direction = [next_x,next_y,next_level]
      if !$part_two
        # try first
        possible_directions.unshift(direction)
      else
        # try last
        possible_directions << direction
      end
    end

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

def traverse_map(map, x, y, level, final_x, final_y, final_level, steps = 0, previous_steps = [], backtracking = [], branches_taken = [], portals_used = [])
  $paths_found << steps if [x,y,level] == [final_x,final_y,final_level]
  return if $paths_found.length > 0 and $exit

  current_level = level
  backtracked = false

#  puts [x,y,level].join(',')
  
  symbols = ['#'] + $letters
  possible_directions = find_possible_directions(map,x,y,level,symbols,previous_steps,backtracking,branches_taken,final_x,final_y,final_level,portals_used)
  previous_steps << [x,y,level]
  
  if possible_directions.length > 1 # pick one 
    if possible_directions.include?([final_x, final_y, final_level]) # voila
      x,y,level = [final_x, final_y, final_level]
    else
      portals = []
      $portals_by_map.keys.each do | x, y |
        portals << [x,y,level]
      end
      if !$part_two and (possible_directions & portals).length > 0
        portal = possible_directions & portals
        x,y,level = portal[0]
        possible_directions.delete(portal[0])
      else
        x,y,level = possible_directions.shift
      end
      # save other directions
      backtracking << [possible_directions, steps]
      branches_taken << [x,y,level]
    end
  elsif possible_directions.length == 1  # move forward
    x,y,level = possible_directions[0]
  else # we've hit a dead end
    if backtracking.length > 0 # able to backtrack
      backtracked = true
      possible_directions, new_steps = backtracking.pop
      difference = steps - new_steps
      steps = new_steps
      x,y,level = possible_directions.shift
      branches_taken << [x,y,level]
      backtracking << [possible_directions, steps] if possible_directions.length > 0
      previous_steps.pop(difference)
    else
      return # we've found all the paths
    end
  end
  
  if level != current_level and !backtracked
    portal = $portals_by_map[[x,y]]
    puts "#{portal} to #{level}"
    if level > current_level
      portals_used << [portal, "up"]
    else
      portals_used << [portal, "down"]
    end
  end
  
  steps += 1
  traverse_map(map, x, y, level, final_x, final_y, final_level, steps, previous_steps, backtracking, branches_taken, portals_used)
end

def find_portals(doors)
  doors.delete('AA')
  doors.delete('ZZ')
  portals_by_name = doors

  portals_by_map = {}
  doors.keys.each do | portal |
    ["inner", "outer"].each do | location |
      coordinates = doors[portal][location]
      portals_by_map[coordinates] = portal
    end
  end
  
  return portals_by_name, portals_by_map
end

filename = 'day-20-input.txt' # 714 # ?
#filename = 'day-20-input-3.txt' # x # 396 
#filename = 'day-20-input-2.txt' # 58 # x
#filename = 'day-20-input-1.txt' # 23 # 26 

map = get_map(filename)
doors, $letters = find_doors(map)

start_x, start_y = doors['AA']['outer']
final_x, final_y = doors['ZZ']['outer']

level = 0

$portals_by_name, $portals_by_map = find_portals(doors)

# $paths_found = []
# $exit = true # I can't figure out how to get past the "stack level too deep" error
# traverse_map(map, start_x, start_y, level, final_x, final_y, level)
# steps = $paths_found.min

# puts "PART 1: #{steps}"

$part_two = true
$exit = true # I can't figure out how to get past the "stack level too deep" error
$paths_found = []
traverse_map(map, start_x, start_y, level, final_x, final_y, level)
steps = $paths_found.min

puts "PART 2: #{steps}"

