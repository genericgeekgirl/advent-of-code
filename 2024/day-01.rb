INPUT_FILE = "day-01-input.txt"

column_one = []
column_two = []

count_column_two = {}

count = 0

File.readlines(INPUT_FILE, chomp: true).each do | line |
  id_one, id_two = line.split(/\s+/).map { | x | x.to_s }

  column_one << id_one
  column_two << id_two
  
  count_column_two[id_two] ||= 0
  count_column_two[id_two] += 1
end

column_one.sort!
column_two.sort!

sum = 0

(0..column_one.length-1).each do | i |
  sum += (column_one[i].to_i - column_two[i].to_i).abs
end

puts "PART 1: #{sum}"

score = 0

column_one.each do | id |
  score += (count_column_two[id] || 0) * id.to_i
end

puts "PART 2: #{score}"
