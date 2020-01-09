filename = 'day-12-input.txt'

def get_data(filename)
  File.open(filename).each do |line|
    moon = line.chomp.gsub(/[><]/, '')
    next if moon.length == 0
    coordinates = moon.split(', ')
    positions_hash = {}
    velocity_hash = {}
    coordinates.each do | coordinate |
      axis, value = coordinate.split('=')
      positions_hash[axis] = value.to_i
      velocity_hash[axis] = 0
    end
    $positions << positions_hash
    $velocities << velocity_hash
  end
  return $positions.length
end

def apply_gravity(axis)
  for i in 0..$num_moons-2 do
    for j in i+1..$num_moons-1 do
      moon_a = $positions[i]
      moon_b = $positions[j]
      #    ['x','y','z'].each do |axis|
        a = moon_a[axis]
        b = moon_b[axis]
        if a > b
          $velocities[i][axis] -= 1
          $velocities[j][axis] += 1
        elsif a < b
          $velocities[i][axis] += 1
          $velocities[j][axis] -= 1
        end
      end
#    end
  end
end

def apply_velocity(axis)
  for moon in 0..$num_moons-1 do
    #    ['x','y','z'].each do |axis|
      $positions[moon][axis] += $velocities[moon][axis]
#    end
  end
end

def check_cycle(axis)
  for moon in 0..$num_moons-1 do
    return false if $velocities[moon][axis] != 0
  end
  return true
end

def calculate_total_energy
  energy = 0

  for moon in 0..$num_moons-1 do
    total_energy = 0
    potential_energy = 0
    kinetic_energy = 0
    $positions[moon].keys.each do | axis |
      potential_energy += $positions[moon][axis].abs
      kinetic_energy += $velocities[moon][axis].abs
    end
    total_energy = potential_energy * kinetic_energy    
    energy += total_energy
  end
    
  return energy
end

$positions = []
$velocities = []

$num_moons= get_data(filename)

# steps = 0

# while steps < 1000
#   apply_gravity
#   apply_velocity
#   energy = calculate_total_energy
#   steps += 1
# end

# puts energy

$original_positions = []

for moon in 0..$positions.length-1 do
  $original_positions[moon] = {}
  $positions[moon].keys.each do | axis |
    $original_positions[moon][axis] = $positions[moon][axis]
  end
end

cycles = {}

['x','y','z'].each do |axis|
  steps = 0
  while true
    apply_gravity(axis)
    apply_velocity(axis)
    steps += 1
    break if check_cycle(axis)
  end
  cycles[axis] = steps
end

least_common_multiple = cycles.values.reduce(1, :lcm)
solution = least_common_multiple*2

puts solution


