input_file = "day-06-input.txt"

def find_marker(sequence, marker_length)
  pointer = 0
  while pointer <= sequence.length - marker_length
    possible_marker = sequence.slice(pointer, marker_length)
    return pointer + marker_length if possible_marker.uniq.size == marker_length
    pointer += 1
  end
end

sequence = File.read(input_file).chomp.split('')

puts "Part 1: #{find_marker(sequence, 4)}"
puts "Part 1: #{find_marker(sequence, 14)}"


