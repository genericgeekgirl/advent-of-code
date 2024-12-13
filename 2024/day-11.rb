INPUT_FILE = "day-11-input.txt"

@stones = File.read(INPUT_FILE).chomp.split(' ').map(&:to_i)

@chart = {}

def blink(times, stone)
  return 1 if times == 0

  key = [stone, times]
  return @chart[key] if @chart.has_key?(key)

  if stone == 0
    count = blink(times-1, 1)
  else  
    digits = stone.to_s.split('')
    if digits.length % 2 == 0
      mid_point = digits.length/2
      left_stone = digits[..mid_point-1].join('').to_i
      right_stone = digits[mid_point..].join('').to_i
      count = blink(times-1, left_stone) + blink(times-1, right_stone)
    else
      count = blink(times-1, stone * 2024)
    end
  end

  @chart[key] = count
  return count
end

def blink_wrapper(times, stones)
  return stones.map { | stone | blink(times, stone) }.sum
end

stones_count_1 = blink_wrapper(25, @stones)
puts "PART 1: #{stones_count_1}"

stones_count_2 = blink_wrapper(75, @stones)
puts "PART 2: #{stones_count_2}"
