
INPUT_FILE = "day-03-input.txt"
@content = File.read INPUT_FILE

def part_1(content)
  sum = 0
  
  instructions = content.scan(/mul\(\d{1,3},\d{1,3}\)/)
  
  instructions.each do | instruction |
    numbers = instruction.scan(/\d{1,3}/)
    sum += numbers[0].to_i * numbers[1].to_i
  end
  
  sum
end

def part_2(content)
  sum = 0
  
  chunks = content.split("don't()")

  sets = [chunks[0]] + chunks[1..].map { | chunk | chunk.split("do()", 2)[1] }.compact

  sets.each do | set |
    sum += part_1(set)
  end

  sum 
end

puts "PART 1: #{part_1(@content)}"
puts "PART 2: #{part_2(@content)}"
