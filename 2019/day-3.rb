
$instructions = []

File.open('day-3-input.txt').each do |wire|
  wire_instructions = wire.chomp.split(',')
  $instructions << wire_instructions
end

$wire_1 = {0 => 0, 1 => 0}
  
$center_x = 0
$center_y = 0

$x = 0
$y = 1

def place_wire(n)
  $last_position = [$center_x, $center_y]
  $instructions[n].each do |instruction|
    direction = instruction[0]
    steps = instruction[1..-1].to_i
    take_steps(n, direction, steps)
  end
end

def take_steps(wire, direction, steps)
  for i in 1..steps do
    case direction
    when "U"
      $last_position = [$last_position[$x], $last_position[$y] + 1]
    when "D"
      $last_position = [$last_position[$x], $last_position[$y] - 1]
    when "L"
      $last_position = [$last_position[$x] - 1, $last_position[$y]]
    when "R"
      $last_position = [$last_position[$x] + 1, $last_position[$y]]
    end
    if wire == 0
      $wire_1[$last_position] = 1
    elsif wire == 1
      if $wire_1[$last_position]
        $intersections << $last_position
        puts "Intersection found at [#{$last_position[$x]}, #{$last_position[$y]}]"
      end
    end
  end
  puts "moving wire #{wire+1} #{direction} #{steps} steps to position [#{$last_position[$x]}, #{$last_position[$y]}]"
end

def count_steps(n, intersection)
  $last_position = [$center_x, $center_y]

  steps_taken = 0
  
  $instructions[n].each do |instruction|
    direction = instruction[0]
    steps = instruction[1..-1].to_i
    
    for i in 1..steps do
      case direction
      when "U"
        $last_position = [$last_position[$x], $last_position[$y] + 1]
      when "D"
        $last_position = [$last_position[$x], $last_position[$y] - 1]
      when "L"
        $last_position = [$last_position[$x] - 1, $last_position[$y]]
      when "R"
        $last_position = [$last_position[$x] + 1, $last_position[$y]]
      end

      steps_taken += 1
      
      if intersection == $last_position
        return steps_taken
      end
    end
  end
end

$intersections = []

for n in 0..$instructions.length-1 do
  place_wire(n)
end

find_minimum_steps = []

$intersections.each do |intersection|
  steps_to_intersection = 0
  for n in 0..$instructions.length-1 do
    steps_to_intersection += count_steps(n, intersection)
  end
  find_minimum_steps << steps_to_intersection
end

puts find_minimum_steps.min

