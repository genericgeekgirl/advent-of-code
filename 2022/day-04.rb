file = 'day-04-input.txt'

def process_line(line)
  a_1, a_2 = line.chomp.split(',').map { | assignment | process_range(assignment) }
end

def process_range(assignment)
  match = assignment.match(/(?<first>\d+)-(?<last>\d+)/); 
  return (match[:first].to_i..match[:last].to_i).to_a
end

def ranges_completely_overlap(foo, bar)
  return (foo-bar).empty? || (bar-foo).empty?
end

def ranges_overlap_at_all(foo, bar)
  return !(foo.intersection(bar).empty?)
end

def part_1(file)
  overlap_count = 0
  File.open(file).each do |line|
    a_1, a_2 = process_line(line)
    overlap_count += 1 if ranges_completely_overlap(a_1, a_2)
  end
  overlap_count
end

puts "Part 1: #{part_1(file)}"
 
def part_2(file)
  overlap_count = 0
  File.open(file).each do |line|
    a_1, a_2 = process_line(line)
    overlap_count += 1 if ranges_completely_overlap(a_1, a_2) || ranges_overlap_at_all(a_1, a_2)
  end
  overlap_count
end

puts "Part 2: #{part_2(file)}"
