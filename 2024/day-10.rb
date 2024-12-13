INPUT_FILE = "day-10-input.txt"

@map = []

File.readlines(INPUT_FILE, chomp: true).each do | line |
  @map << line.split('').map(&:to_i)
end

trailheads = {}

START_POINT = 0
END_POINT = 9

ROWS = @map.length
COLUMNS = @map[0].length

def walk_map(row, column, height)
  height_at_location = @map[row][column]
  
  return [nil] if height_at_location != height
  return [[row, column]] if height == END_POINT
  
  up = (row - 1 >= 0) ? walk_map(row - 1, column, height + 1) : [nil]
  down = (row + 1 < ROWS) ? walk_map(row + 1, column, height + 1) : [nil]
  left = (column - 1 >= 0) ? walk_map(row, column - 1, height + 1) : [nil]
  right = (column + 1 < COLUMNS) ? walk_map(row, column + 1, height + 1) : [nil]

  return up + down + left + right
end

(0..ROWS-1).each do | row |
  indicies = @map[row].join('').enum_for(:scan, /#{START_POINT}/).map { Regexp.last_match.begin(0) }
  indicies.each do | column |
    positions = walk_map(row, column, START_POINT)
    rating = positions.compact.count
    score = positions.compact.uniq.count
    trailheads[[row,column]] = [score, rating] if score > 0
  end
end

total_score = 0
total_rating = 0

trailheads.each do | _start, data |
  score, rating = data
  total_score += score
  total_rating += rating
end

puts "PART 1: #{total_score}"
puts "PART 2: #{total_rating}"

                         

