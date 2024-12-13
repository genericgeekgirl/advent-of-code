calories_by_elf = []
total_calories = 0

File.open('day-01-input.txt').each do |line|
  entry = line.chomp
  if entry.empty?
    calories_by_elf << total_calories
    total_calories = 0
    next
  end
  total_calories += entry.to_i
end

puts "PART 1: #{calories_by_elf.max}"

top_three_elves = calories_by_elf.sort.reverse.first(3).sum

puts "PART 2: #{top_three_elves}"
