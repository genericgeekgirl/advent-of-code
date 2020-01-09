
$orbit_hash = {}

File.open('day-6-input.txt').each do |line|
#File.open('foo2.txt').each do |line|
  orbit = line.chomp.split(')')
  next if orbit.length == 0
  inner = orbit[0]
  outer = orbit[1]

  if !$orbit_hash[inner]
    $orbit_hash[inner] = []
  end
  
  $orbit_hash[inner] << outer
end

$orbit_hash_saved = $orbit_hash.dup

$orbit_array = []
$orbit_count = 0

def backtrack(array)
  last = array.pop
  if $orbit_hash[last] and $orbit_hash[last].length > 0
    return last
  else
    if $heads.include?(last)
      return nil
    else
      backtrack(array)
    end
  end
end

$route_to_you = []
$route_to_santa = []

def calculate_transfers
  require "set"
  x = Set.new($route_to_you)
  y = Set.new($route_to_santa)
  set = x.intersection y

  santa_index = $route_to_santa.index("SAN")
  santa_orbits = $route_to_santa[santa_index - 1]
  you_index = $route_to_you.index("YOU")
  you_orbit = $route_to_you[you_index - 1]
  last_shared_point = set.to_a.last

  index1 = $route_to_santa.index(last_shared_point)
  index2 = $route_to_santa.index(santa_orbits)

  santa_diff = (index2 - index1).abs
  
  index3 = $route_to_you.index(last_shared_point)
  index4 = $route_to_you.index(you_orbit)

  you_diff = (index4 - index3).abs
  
  return you_diff + santa_diff
end

def find_end_of_orbit(inner, outer_array)
  $orbit_array << inner

  outer = outer_array.shift

  if !$orbit_hash[outer]
    $orbit_array << outer

    if outer == "YOU"
      $route_to_you = $orbit_array.dup
    elsif outer == "SAN"
      $route_to_santa = $orbit_array.dup
    end

    last = backtrack($orbit_array)
      
    if last.nil?
      return
    end

    find_end_of_orbit(last, $orbit_hash[last])
      
  else
    find_end_of_orbit(outer, $orbit_hash[outer])
  end
end

def find_head()
  heads = []
  $all_orbits = []
  
  $orbit_hash.each do |key, value_array|
    $all_orbits += value_array
  end

  $orbit_hash.keys.each do |key|
    key_found = false
    if $all_orbits.include?(key)
      key_found = true
    end
    if !key_found
      heads << key
    end
  end
  return heads
end

$heads = find_head()

$heads.each do | head |
  find_end_of_orbit(head, $orbit_hash[head])
end

puts $route_to_you.join(" -> ")
puts $route_to_santa.join(" -> ")

jumps = calculate_transfers
puts jumps;
