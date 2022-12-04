file = 'day-03-input.txt'

def part_1(file)
  priority_sum = 0
  
  File.open(file).each do |line|
    rucksack = line.chomp
    
    first, second = rucksack.chars.each_slice(rucksack.length / 2).map(&:to_a)
    
    shared = first.intersection(second)
    
    shared.each do | char |
      priority = get_priority(char)
      priority_sum += priority
    end
  end
  
  return priority_sum
end

def get_priority(char)
  priority = char.downcase.ord - 96
  priority += 26 if /[[:upper:]]/.match(char)
  return priority
end  

puts "Part 1: #{part_1(file)}"
 
def part_2(file)
  priority_sum = 0
  f = File.open(file)
  lines = 3

  while !f.eof?
    elves = []
    lines.times do
      line = f.gets.chomp
      rucksack = line.chars.uniq
      elves << rucksack
    end
    badge = elves.inject(:&)
    if badge.size == 1
      priority = get_priority(badge.first)
    else
      # error
    end
    priority_sum += priority
  end

  f.close
  
  return priority_sum
end

puts "Part 2: #{part_2(file)}"
