input_signal = File.read("day-16-input.txt").chomp

# TESTING PART 1
#input_signal = 69317163492948606335995924319873 # 52432133
#input_signal = 19617804207202209144916044189917 # 73745418
#input_signal = 80871224585914546619083218645595 # 24176176

# TESTING PART 2
#input_signal = "03036732577212944063491565474664" # 84462026
#input_signal = "02935109699940807407585447034323" # 78725270
#input_signal = "03081770884921959731165446850517" # 53553731

digits = input_signal.to_s.split('').map(&:to_i)

offset = -1
#offset = digits[0,7].join('').to_i

#digits = Array.new(10000, digits).flatten

base_pattern = [0, 1, 0, -1]

patterns = []

for i in 0..digits.length-1 do
  pattern = []

  for j in 0..base_pattern.length-1 do
    pattern += Array.new(i+1, base_pattern[j])
  end

  pattern = Array.new((digits.length/pattern.length) + 1, pattern).flatten[1, digits.length]
  patterns[i] = pattern
end

100.times do
  sums = []
  for i in 0..digits.length-1 do
    sums << digits.zip(patterns[i]).map{|x, y| x * y}.reduce(:+).abs % 10
  end
  digits = sums
end

puts digits[offset+1, 8].join('')
