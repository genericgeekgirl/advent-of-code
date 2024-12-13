INPUT_FILE = "day-12-input.txt"

@garden = []

File.readlines(INPUT_FILE, chomp: true).each do | line |
  @garden << line.split('')
end

ROWS = @garden.length
COLUMNS = @garden[0].length

def walk_garden(plant, initial, row, column)
  if @visited.has_key?([row, column])
    return 0 if @garden[row][column] == plant
    return 1
  end
  
  if @garden[row][column] == plant
    @regions[initial] << [row, column]
    @visited[[row, column]] = true

    up = (row - 1 >= 0) ? walk_garden(plant, initial, row - 1, column) : 1
    down = (row + 1 < ROWS) ? walk_garden(plant, initial, row + 1, column) : 1
    left = (column - 1 >= 0) ? walk_garden(plant, initial, row, column - 1) : 1
    right = (column + 1 < COLUMNS) ? walk_garden(plant, initial, row, column + 1) : 1

    return up + down + left + right
  end
  
  return 1
end

def next_unvisited_location(plot)
  row, column = plot

  (column+1..COLUMNS-1).each do | j |
    return [row, j] if !@visited.has_key?([row, j])
  end
  (row+1..ROWS-1).each do | i |
    (0..COLUMNS-1).each do | j |
      return [i, j] if !@visited.has_key?([i, j])
    end
  end
end

@visited = {}
@regions = {}

price = 0

row = column = 0

while @visited.length < ROWS * COLUMNS  
  plant = @garden[row][column]
  plot = [row, column]
  @regions[plot] = []
  price += walk_garden(plant, plot, row, column) * @regions[plot].count
  row, column = next_unvisited_location(plot)
end

puts "PART 1: #{price}"

def count_corners(position, plots)
  row, column = position
  corners = 0
  
  # left and up
  corners += 1 if !plots.include?([row, column - 1]) && !plots.include?([row - 1, column])
  corners += 1 if plots.include?([row, column - 1]) && plots.include?([row - 1, column]) && !plots.include?([row - 1, column - 1])

  # right and down
  corners += 1 if !plots.include?([row, column + 1]) && !plots.include?([row + 1, column])
  corners += 1 if plots.include?([row, column + 1]) && plots.include?([row + 1, column]) && !plots.include?([row + 1, column + 1])

  # left and down
  corners += 1 if !plots.include?([row, column - 1]) && !plots.include?([row + 1, column])
  corners += 1 if plots.include?([row, column - 1]) && plots.include?([row + 1, column]) && !plots.include?([row + 1, column - 1])

  # right and up
  corners += 1 if !plots.include?([row, column + 1]) && !plots.include?([row - 1, column])
  corners += 1 if plots.include?([row, column + 1]) && plots.include?([row - 1, column]) && !plots.include?([row - 1, column + 1])

  return corners
end

bulk_price = 0

@regions.each do | initial, plots |
  corners = plots.map { | position | count_corners(position, plots) }.sum
  plant = @garden[initial[0]][initial[1]]
  bulk_price += corners * plots.count
end

puts "PART 2: #{bulk_price}"
