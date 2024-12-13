INPUT_FILE = "day-06-input.txt"

@rows = 0
@colummns = 0
obstacles = []

NEXT_STEP = {'^' => [-1, 0], '>' => [0, 1], 'v' => [1, 0], '<' => [0, -1]}
TURN_RIGHT = NEXT_STEP.keys.cycle

direction = nil
position = nil

File.readlines(INPUT_FILE, chomp: true).each do | line |
  break if line.empty?

  @colummns = line.length if @colummns == 0

  if position.nil? && direction.nil?
    match = line.match(/<|>|\^|v/)
    if !match.nil?
      direction = match.to_s
      index = line.index(direction)
      position = [@rows, index]
    end
  end
    
  obstacle_indexes = line.enum_for(:scan, /\#/).map { Regexp.last_match.begin(0) }
  obstacle_indexes.each do | index |
    obstacles << [@rows, index]
  end                  

  @rows += 1
end

def walk(visited, position, direction, obstacles)
  row = position[0] + NEXT_STEP[direction][0]
  column = position[1] + NEXT_STEP[direction][1]
  
  if obstacles.include?([row, column])
    direction = TURN_RIGHT.next
  else
    visited << [position, direction]
    position = [row, column]
  end
  
  return position, direction, visited
end

def get_next_step(position, direction)
  row = position[0] + NEXT_STEP[direction][0]
  column = position[1] + NEXT_STEP[direction][1]

  return [row, column]
end

def find_loops(visited, position, direction, obstacles)
  next_step = get_next_step(position, direction)

  if obstacles.include?(next_step)
    direction = TURN_RIGHT.next
  else
    if visited.has_key?(position) && visited[position].include?(direction)
      @loop_found = true
    else
      visited[position] ||= []
      visited[position] << direction
      position = next_step
    end
  end

  return position, direction, visited
end
  
def on_grid(position)
  position[0] >= 0 && position[0] < @rows &&
    position[1] >= 0 && position[1] < @colummns  
end

visited = []

while TURN_RIGHT.next != direction do
end

while on_grid(position) do
  position, direction, visited = walk(visited, position, direction, obstacles)
end

count = visited.map { | position, direction | position }.uniq.count
puts "PART 1: #{count}"

path_walked = visited

loops = []

# given the route the guard will normally take,
# try putting obstacles in his way at each step
(0..path_walked.length-2).each do | i |
  position, direction = path_walked[i]
  obstacle_position = path_walked[i+1][0]

  # obviously don't try to add an obstacle if there's already one there
  next if obstacles.include?(obstacle_position)

  # if we've already walked there, then we've tried to place an obstacle there
  visited = {}
  path_walked[0..i-1].each do | position, direction |
    visited[position] ||= []
    visited[position] << direction
  end

  next if visited.has_key?(obstacle_position)

  # add new obstacle and give it a whirl
  test_obstacles = obstacles.dup
  test_obstacles << obstacle_position

  # as before, let's get oriented
  while TURN_RIGHT.next != direction do
  end

  @loop_found = false

  # stop if we fall off the grid
  while on_grid(position) do
    position, direction, visited = find_loops(visited, position, direction, test_obstacles)

    # w00t
    if @loop_found
      loops << obstacle_position
      puts obstacle_position.join(',')
      break
    end
  end
end

puts "PART 2: #{loops.count}"
