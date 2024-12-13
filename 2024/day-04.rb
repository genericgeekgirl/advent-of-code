
STRING_1 = "XMAS"

INPUT_FILE = "day-04-input.txt"

grid = []

File.readlines(INPUT_FILE, chomp: true).each do | line |
  grid << line.split('')
end

xmas_count = 0

# forwards and backwards

grid.each do | row |
  xmas_count += row.join('').scan(/#{STRING_1}/).count
  xmas_count += row.join('').scan(/#{STRING_1.reverse}/).count
end

# up and down

grid.transpose.each do | column |
  xmas_count += column.join('').scan(/#{STRING_1}/).count
  xmas_count += column.join('').scan(/#{STRING_1.reverse}/).count
end

# diagonals

diagonals = []

diagonals_down = []

(0..grid[0].length-1).each do | x |
  array = []
  init_i = i = 0
  init_j = j = x

  while j < grid.length && i < grid[x].length do 
    array << grid[i][j]
    i += 1
    j += 1
  end
  diagonals << array
  diagonals_down << { i: init_i, j: init_j, letters: array }
end

(1..grid.length-1).each do | x |
  array = []
  init_i = i = x
  init_j = j = 0
  while j < grid.length && i < grid[x].length do 
    array << grid[i][j]
    i += 1
    j += 1
  end
  diagonals << array
  diagonals_down << { i: init_i, j: init_j, letters: array }
end

diagonals_up = []

(0..grid[0].length-1).reverse_each do | x |
  array = []
  init_i = i = x
  init_j = j = 0
  while j < grid.length && i >= 0 do
    array << grid[i][j]
    i -= 1
    j += 1
  end
  diagonals << array
  diagonals_up << { i: init_i, j: init_j, letters: array }
end

(1..grid.length-1).each do | x |
  array = []
  init_i = i = grid.length-1
  init_j = j = x
  while j < grid.length && i >= 0 do 
    array << grid[i][j]
    i -= 1
    j += 1
  end
  diagonals << array
  diagonals_up << { i: init_i, j: init_j, letters: array }
end

diagonals.each do | diagonal |
  xmas_count += diagonal.join('').scan(/#{STRING_1}/).count
  xmas_count += diagonal.join('').scan(/#{STRING_1.reverse}/).count
end

puts "PART 1: #{xmas_count}"

STRING_2 = "MAS"

def find_on_diagonal(array, direction)
  points = []
  array.each do | diagonal |
    letters = diagonal[:letters].join('')

    indices = letters.enum_for(:scan, /#{STRING_2}/).map { Regexp.last_match.begin(0) }
    indices += letters.enum_for(:scan, /#{STRING_2.reverse}/).map { Regexp.last_match.begin(0) }

    indices.each do | index |
      middle = STRING_2.length/2 + index
      i = diagonal[:i] + direction*middle
      j = diagonal[:j] + middle

      points << [i, j]
    end
  end
  return points
end

cross_count = (find_on_diagonal(diagonals_down, 1) & find_on_diagonal(diagonals_up, -1)).count

puts "PART 1: #{cross_count}"
