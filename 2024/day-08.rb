INPUT_FILE = "day-08-input.txt"

@height = 0
@width = 0

antennae = {}

File.readlines(INPUT_FILE, chomp: true).each do | line |
  @width = line.length if @width == 0
  
  positions = line.split('')

  line.scan(/[A-Za-z0-9]/) do | match |
    antennae[match] ||= []
    index = Regexp.last_match.offset(0)[0]
    antennae[match] << [@height, index]
  end
  
  @height += 1
end

def find_antinodes(positions)
  antinodes = []
  
  pairs = positions.combination(2).to_a
  pairs.each do | a, b |
    x = b[0] - a[0]
    y = b[1] - a[1]

    antinode_a = [a[0] - x, a[1] - y]
    antinode_b = [b[0] + x, b[1] + y]

    [antinode_a, antinode_b].each do | antinode |
      if antinode[0] >= 0 && antinode[0] < @height && antinode[1] >= 0 && antinode[1] < @width 
        antinodes << antinode
      end
    end
  end

  return antinodes
end

antinodes = []

antennae.each do | antenna, positions |
  antinodes += find_antinodes(positions)
end

puts "PART 1: #{antinodes.uniq.count}"

def find_antinodes_part_2(positions)
  antinodes = []

  if positions.size >= 2
    antinodes += positions
  end
  
  pairs = positions.combination(2).to_a
  pairs.each do | a, b |
    x = b[0] - a[0]
    y = b[1] - a[1]

    if x == 0
      (0..@width-1).each do | j |
        antinodes << [a[0], j]
      end

    elsif y == 0
      (0..@height-1).each do | i |
        antinodes << [i, a[1]]
      end

    else
      i, j = a
      while true do
        i -= x
        j -= y
        break if i < 0 || i >= @height || j < 0 || j >= @width
        antinode = [i, j]
        antinodes << antinode
      end

      i, j = a
      while true do
        i += x
        j += y
        break if [i, j] == b
        antinode = [i, j]
        antinodes << antinode
      end
      
      i, j = b
      while true do
        i += x
        j += y
        break if i < 0 || i >= @height || j < 0 || j >= @width
        antinode = [i, j]
        antinodes << antinode
      end
    end
  end

  return antinodes
end

antinodes = []

antennae.each do | antenna, positions |
  antinodes += find_antinodes_part_2(positions)
end

puts "PART 2: #{antinodes.uniq.count}"
