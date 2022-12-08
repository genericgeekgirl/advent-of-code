input_file = "day-08-input.txt"

patch = []

File.open(input_file).each do |line|
  patch << line.chomp.split('')
end

def process_input(patch, part)
  visibility = []
  scenic_score = []

  (0..patch.size-1).each do | x |
    visibility[x] = []
    scenic_score[x] = []
    (0..patch[x].size-1).each do | y |
      if (x == 0 || x == patch.size-1 ||
          y == 0 || y == patch[x].size-1)
        # along one of the edges
        visibility[x][y] = 1 if part == 1
        next if part == 2
      else
        left = patch[x].slice(0,y)
        right = patch[x].slice(y+1, patch[x].size-y-1)
        column = patch.transpose[y]
        top = column.slice(0, x)
        down = column.slice(x+1, patch.size-(x+1))

        if part == 1
          [left, right, top, down].each do | a |
            unless a.max >= patch[x][y]
              visibility[x][y] = 1
            end
          end
        end
        
        if part == 2
          viewing_distance = []
          [left.reverse, right, top.reverse, down].each do | a |
            too_tall = a.map.with_index { |value, i| (value >= patch[x][y]) ? i : nil}.compact
            if too_tall.empty?
              viewing_distance << a.size
            else
              viewing_distance << too_tall.first + 1
            end
          end
          scenic_score[x][y] = viewing_distance.inject(:*)          
        end
      end
    end
  end
  return visibility if part == 1
  return scenic_score if part == 2
end

visibility = process_input(patch, 1)
visible = visibility.flatten.compact.sum

puts "Part 1: #{visible}"

scenic_score = process_input(patch, 2)
best_view = scenic_score.flatten.compact.max

puts "Part 2 #{best_view}"
