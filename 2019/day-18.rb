
def get_map(filename)
  map = []
  File.open(filename).each do |line|
    map << line.chomp.split('')
  end
  return map
end

def find_entrance
  entrance = '@'
  for i in 0..$map.length-1 do
    if $map[i].include?(entrance)
      y = i
      x = $map[i].index(entrance)
      return [x,y]
    end
  end
end

def find_keys_and_doors
  upper_alphabet = [*"A".."Z"].to_a
  lower_alphabet = [*"a".."z"].to_a 
  full_map = $map.join('').split('')

  doors = full_map & upper_alphabet
  keys = full_map & lower_alphabet

  keys_with_coordinates = {}
  keys.each do | key |
    for y in 0..$map.length-1 do
      if $map[y].include?(key)
        x = $map[y].index(key)
        keys_with_coordinates[key] = [x,y]
        break
      end
    end
  end
    
  return [keys_with_coordinates, doors]
end

def find_possible_directions(x,y,symbols, previous_steps)
  possible_directions = []
  possible_directions << [x, y-1] if !symbols.include?($map[y-1][x])
  possible_directions << [x+1, y] if !symbols.include?($map[y][x+1])
  possible_directions << [x, y+1] if !symbols.include?($map[y+1][x])
  possible_directions << [x-1, y] if !symbols.include?($map[y][x-1])

  #remove going backwards, since we have code to backtrack
  if previous_steps.length > 0
    previously_visited = possible_directions & previous_steps
    possible_directions = possible_directions - previously_visited
  end
  
  return possible_directions
end


def get_routes(x,y)
  require 'set'

  key_distances = {}
  key_doors = {}
  
  key_distances['@'], key_doors['@'] = calculate_distances(x, y, $keys, $doors)

  pairs = $keys.keys.combination(2).to_a

  keys_to_find = {}
  pairs.each do | start, finish |
    keys_to_find[start] = [] if keys_to_find[start].nil?
    keys_to_find[start] << finish
  end
  
  keys_to_find.each do | start, keys |
    x, y = $keys[start]
    key_distances[start], key_doors[start] = calculate_distances(x, y, keys, $doors)
  end

  max_size = 9

  key = '@'
  route = []
  route << key
  possible_routes = []
  possible_routes << route
  
  if $keys.length > max_size
    puts "GETTING POSSIBILITIES"
    
    possible_routes = get_route_possibilities(key_doors, route)

    route_1 = possible_routes[0].dup
    while ($keys.keys - route_1).length > 0

      doors = key_doors.dup
      possibilities = possible_routes.dup

      skip = []
      
      possibilities.each do | route |
        next if skip.include?(route)
        skip << route
        valid_combinations = []
        possibilities.each do | possibility |
          next if route == possibility
          if Set.new(route) == Set.new(possibility)
            valid_combinations << possibility
            skip << possibility
          end
        end

        doors = check_doors_with_route_keys(route.dup, doors)
        routes = get_route_possibilities(doors, route, valid_combinations)
        possible_routes += routes
      end

      possible_routes -= skip
      
      route_1 = possible_routes[0].dup
      route_1.shift
    end

  else
    possible_routes = build_routes(possible_routes, key_doors)
  end
    
  return [possible_routes, key_distances]
end


def check_doors_with_route_keys(route, doors)
  route.shift if route.first == '@'
  
  doors.keys.each do | first_key |
    doors.keys.each do | second_key |
      next if first_key == second_key
      route.each do | door |
        if doors[first_key][second_key]
          doors[first_key][second_key].delete(door.upcase)
        else
          doors[second_key][first_key].delete(door.upcase)
        end
      end
    end
  end

  return doors
end


def build_routes(possible_routes, key_doors)
  puts "BUILDING ROUTES"

  keys_added = 0      
  
  keys_to_find = {}
  $keys.keys.each do | key |
    keys_to_find[key] = $keys.keys - [key]
  end
  keys_to_find['@'] = $keys.keys

  while keys_added < $keys.length do
    keys_added += 1
    more_routes = []

    possible_routes.each do | route |
      last_key = route.last
      next_keys = keys_to_find[last_key]
      keys = next_keys - route

      keys.each do | key |        
        if key_doors[last_key].nil? or key_doors[last_key][key].nil?
          these_doors = key_doors[key][last_key]
        else
          these_doors = key_doors[last_key][key]
        end          
        doors = these_doors ? these_doors - route.map { | key | key.upcase } - [key.upcase] : []
        if doors.length == 0
          more_routes << route + [key]
        end
      end
    end
    possible_routes.shift
    possible_routes += more_routes
  end

  valid_routes = []
  possible_routes.each do | route |
    if route.length == keys_added + 1
      valid_routes << route
    end
  end

  return valid_routes
end


def get_route_possibilities(key_doors, existing_route, valid_combinations = [])
  puts existing_route.join(',')
  
  set_size = 3
  possible_routes = []  
  
  # generate starter sequences
  keys = $keys.keys - existing_route
  
  if keys.length < set_size
    set_size = keys.length
  end
  
  permutations = keys.permutation(set_size).to_a
  permutations = permutations.sort

  valid_combinations.unshift(existing_route)

  # check which of these sequences are usuable
  while permutations.length > 0
    route = permutations.shift
    path = route.dup
    path.unshift(existing_route.last)
    keys = []
    delete = false
    while path.length > 1
      key = path.shift
      next_key = path[0]
      keys << next_key
      if key_doors[key].nil? or key_doors[key][next_key].nil?
        if key_doors[next_key].nil? or key_doors[next_key][key].nil?
          these_doors = nil
        else
          these_doors = key_doors[next_key][key]
        end
      else
        these_doors = key_doors[key][next_key]
      end
      doors = these_doors ? these_doors - keys.map { | key | key.upcase } - [key.upcase] : []
      unless doors.length == 0
        delete = true
        break
      end
    end
    if delete
      keys.shift(existing_route.length)
      # delete all permutations starting with keys
      permutations.each do | path |
        if path[0, keys.length] == keys
          permutations.delete(path)
        end
      end
    else
      valid_combinations.each do | combo |
        path = route.dup
        combo.shift if combo.first == '@'
        path = path.unshift(combo).flatten
        possible_routes << path
      end
    end
  end

  return possible_routes
end


def calculate_distances(x, y, keys, doors, starting_x = x, starting_y = y, keys_seen = {}, doors_in_the_way = {}, doors_seen = {}, steps = 0,  previous_steps = [], backtracking = [])

  character = $map[y][x]
  
  if keys.include?(character) and !keys_seen.include?(character)
    keys_seen[character] = steps
    doors_in_the_way[character] = doors_seen.keys
    if keys_seen.length == keys.length
      return [keys_seen, doors_in_the_way]
    end
  elsif doors.include?(character) and !doors_seen.include?(character)
    doors_seen[character] = steps
  end

  symbols = ['#']
  possible_directions = find_possible_directions(x,y,symbols,previous_steps)
  previous_steps << [x,y]

  if possible_directions.length > 1  # save other routes
    x,y = possible_directions.shift
    backtracking << [possible_directions, steps]
  elsif possible_directions.length == 1 # move forward
    x,y = possible_directions[0]
  else # need to backtrack
    if backtracking.length > 0
      possible_directions, steps = backtracking.pop
      x,y = possible_directions.shift
      backtracking << [possible_directions, steps] if possible_directions.length > 0
      doors_seen.each do | door, steps_to_door |
        if steps_to_door > steps
          doors_seen.delete(door)
        end
      end
    else # we're done
      return [keys_seen, doors_in_the_way]
    end
  end

  steps += 1
  calculate_distances(x, y, keys, doors, starting_x, starting_y, keys_seen, doors_in_the_way, doors_seen, steps, previous_steps, backtracking)
end

def collect_keys(entrance_x, entrance_y)
  possible_routes, key_distances = get_routes(entrance_x,entrance_y)

  puts "COLLECTING KEYS"
  
  steps_for_route = {}

  while possible_routes.length > 0
    steps = 0

    keys = $keys.dup
    doors = $doors.dup

    key_path = possible_routes.shift
    route = key_path.dup

    possible = true

    route_keys = []
    
    while key_path.length > 1
      key = key_path.shift
      next_key = key_path[0]
      
      if key_distances[key].nil? or key_distances[key][next_key].nil?
        distance = key_distances[next_key][key]
      else
        distance = key_distances[key][next_key]
      end

      steps += distance
      
      keys.delete(next_key)
      doors.delete(next_key.upcase)
    end

    route.shift
    steps_for_route[route.join(',')] = steps
  end

  route, steps = steps_for_route.min_by{ |k,v| v }

  return route, steps
end

#filename = 'day-18-input.txt' # NO
#filename = 'foo-5.txt' # 81
filename = 'foo-4.txt' # 136 # NO
#filename = 'foo-3.txt' # 132
#filename = 'foo-2.txt' # 86 
#filename = 'foo-1.txt' # 8 

$map = get_map(filename)
x, y = find_entrance
$keys, $doors = find_keys_and_doors
keys_in_possession, steps = collect_keys(x,y)

puts "#{keys_in_possession} - #{steps}"
