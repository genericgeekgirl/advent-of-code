map = []

filename = 'day-10-input.txt'
#filename = "foo.txt"

File.open(filename).each do |line|
  map << line.chomp.split('')
end

$total_asteroids = 0

map.each do | row |
  $total_asteroids += row.count('#')
end

def count_asteroids(array_original, count_seen, count_remaining)
  array = array_original.dup - ['.']

  count_remaining -= array.count('#')

  string = array.join('')
  if string.include?('#*#')
    count_seen += 2
  elsif (string.include?('#*') or string.include?('*#'))
    count_seen += 1
  end

  return [count_seen, count_remaining]
end

def make_vertical_array(map,x,y, lasers=false)
  vertical_array = []
  for m in 0..map[x].length-1
   if lasers
     vertical_array << "#{x},#{m}" if map[m][x] != '.'
   else
      vertical_array << map[x][m]
      vertical_array[-1] = '*' if m == y
    end
  end
  return vertical_array.compact
end

def make_horizontal_array(map,x,y, lasers=false)
  horizontal_array = []
  for n in 0..map.first.length-1
   if lasers
     horizontal_array << "#{n},#{y}" if map[y][n] != '.'
   else
     horizontal_array << map[n][y]
     horizontal_array[-1] = '*' if n == x
   end
  end
  return horizontal_array.compact
end

def make_diagonal_up_array(map,x,y,i,j, lasers=false)
  diagonal_up_array = lasers ? ["#{x},#{y}"] : ['*']
  n = x+i
  m = y-j
  while n < map[x].length and m >= 0
   if lasers
     diagonal_up_array << "#{n},#{m}" if map[m][n] == '#'
   else
      diagonal_up_array.unshift(map[n][m])
   end
    n += i
    m -= j
  end
  n = x-i
  m = y+j
  while n >= 0 and m < map.length do
   if lasers
     diagonal_up_array.unshift("#{n},#{m}") if map[m][n] == '#'
   else
     diagonal_up_array << map[n][m]
   end
    n -= i
    m += j
  end
  return diagonal_up_array.compact
end

# I massively screwed this up
def make_diagonal_down_array(map,x,y,i,j, lasers=false)
  if lasers
    diagonal_down_array = ["#{x},#{y}"]
    m = x-i
    n = y-j
    while n >= 0 and m >= 0
      diagonal_down_array.unshift("#{m},#{n}") if map[n][m] == '#'
      m -= i
      n -= j
    end
    m = x+i
    n = y+j
    while n < map[x].length and m < map.length do
      diagonal_down_array << "#{m},#{n}" if map[n][m] == '#'
      m += i
      n += j
    end
  else
    diagonal_down_array = ['*']
    n = x-i
    m = y-j
    while n >= 0 and m >= 0
      diagonal_down_array.unshift(map[n][m])
      n -= i
      m -= j
    end
    n = x+i
    m = y+j   
    while n < map[x].length and m < map.length do
      diagonal_down_array << map[n][m]
      n += i
      m += j
    end
  end
  return diagonal_down_array.compact
end

def split_array(array)
  index = array.index("#{$x},#{$y}")
  if index == 0
    array_1 = []
    array_2 = array[1..-1]
  elsif index == array.length-1
    array_1 = array[0..-2]
    array_2 = []
  else
    array_1 = array[0..index-1]
    array_2 = array[index+1..-1]
  end
  return [array_1, array_2]
end

def asteroids_for_laser(map,x, y)
  quad_1 = []
  quad_2 = []
  quad_3 = []
  quad_4 = []

  horizontal_array = make_horizontal_array(map,x,y,true)
  array_left, array_right = split_array(horizontal_array)
  quad_4[0] = array_left.reverse if array_left.length > 0
  quad_2[0] = array_right if array_right.length > 0

  vertical_array = make_vertical_array(map,x,y,true)
  array_up, array_down = split_array(vertical_array)
  quad_1[0] = array_up.reverse if array_up.length > 0
  quad_3[0] = array_down if array_down.length > 0
  
  i_j_hash = {}
  quad_1_hash = {}
  quad_2_hash = {}
  quad_3_hash = {}
  quad_4_hash = {}
  
  i = 1
  while i < map.first.length
    j = 1
    while j < map.length
      fraction = i.to_r/j
      unless i_j_hash[fraction]
        i_j_hash[fraction] = 1

        diagonal_up_array = make_diagonal_up_array(map, x,y,i,j,true)
        array_bottom, array_top = split_array(diagonal_up_array)
        quad_1_hash[fraction] = array_top if array_top.length > 0
        quad_3_hash[fraction] = array_bottom.reverse if array_bottom.length > 0
        
        diagonal_down_array = make_diagonal_down_array(map, x,y,i,j,true)              
        array_top, array_bottom = split_array(diagonal_down_array)
        quad_4_hash[1/fraction] = array_top.reverse if array_top.length > 0
        quad_2_hash[1/fraction] = array_bottom if array_bottom.length > 0
      end
      j += 1
    end
    i += 1
  end

  quad_1 = quad_1 + Hash[quad_1_hash.sort].values
  quad_2 = quad_2 + Hash[quad_2_hash.sort].values
  quad_3 = quad_3 + Hash[quad_3_hash.sort].values
  quad_4 = quad_4 + Hash[quad_4_hash.sort].values

  asteroids = quad_1 + quad_2 + quad_3 + quad_4
  return asteroids
end

def find_coordinates_of_laser(map)
  map_num = []

  for x in 0..map.first.length-1 do
    map_num[x] = []
    for y in 0..map.length-1 do
      char = map[x][y]
      if char == '#'      
        count_seen = 0
        count_remaining = $total_asteroids - 1

        horizontal_array = make_horizontal_array(map, x,y)
        count_seen, count_remaining = count_asteroids(horizontal_array, count_seen, count_remaining)
        vertical_array = make_vertical_array(map, x,y)
        count_seen, count_remaining = count_asteroids(vertical_array, count_seen, count_remaining)

        i_j_hash = {}
        i = 1
        while i < map.first.length
          j = 1
          while j < map.length
            fraction = i.to_r/j
            unless i_j_hash[fraction]
              i_j_hash[fraction] = 1
              diagonal_up_array = make_diagonal_up_array(map, x,y,i,j)
              count_seen, count_remaining = count_asteroids(diagonal_up_array, count_seen, count_remaining)
              diagonal_down_array = make_diagonal_down_array(map, x,y,i,j)              
              count_seen, count_remaining = count_asteroids(diagonal_down_array, count_seen, count_remaining)
            end
            j += 1
          end
          i += 1
        end
        
        map_num[x][y] = count_seen + count_remaining
      else
        map_num[x][y] = 0
      end
    end
  end

  max_num_for_row = []
  max_column_for_row = []

  map_num.each do |row|
    max_num = row.max
    max_num_for_row << max_num
    max_column_for_row << row.index(max_num)
  end

  max_num = max_num_for_row.max
  max_index = max_num_for_row.index(max_num)

  for i in 0..map_num.length-1
    if map_num[max_index][i] == max_num
      y = max_index
      x = i
    end
  end
  
  return [x,y]
end

$x, $y = find_coordinates_of_laser(map)

asteroids = asteroids_for_laser(map,$x,$y)

shot_asteroids = []

total_count = 0
asteroids.each do | line |
  total_count += line.length
end

i = 0
while shot_asteroids.length < $total_asteroids-1 do
  line = asteroids[i]
  asteroid = line.shift
  shot_asteroids << asteroid if !asteroid.nil?
  i += 1
  i = 0 if i >= asteroids.length
end

coordinates = shot_asteroids[200-1]
x, y = coordinates.split(',').map(&:to_i)
puts x*100 + y
