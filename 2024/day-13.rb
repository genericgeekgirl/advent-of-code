INPUT_FILE = "day-13-input.txt"

PRESS_A = 3
PRESS_B = 1

@machines = []

machine = {}

File.foreach(INPUT_FILE) do | line |
  line = line.chomp
  
  if line.empty?
    @machines << machine
    machine = {}
    next
  end
  
  key, x, x_value, y, y_value = line.downcase.split(/[:=+,]\s*/)
  machine[key.gsub(" ", "_")] = [x_value.to_i, y_value.to_i]
end

@machines << machine

def play(machine, offset = 0)
  a_x, a_y = machine["button_a"]
  b_x, b_y = machine["button_b"]
  prize_x, prize_y = machine["prize"].map { | prize | prize + offset }

  # to be winnable:
  #  a_presses * a_x + b_presses * b_x = prize_x
  #  a_presses * a_y + b_presses * b_y = prize_y
  # therefore:
  b_presses = ( (a_x * prize_y) - (a_y * prize_x) ) / ( (a_x * b_y) - (a_y * b_x) )
  a_presses = ( prize_x - (b_presses * b_x) ) / a_x.to_f
  a_presses_2 = ( prize_y - (b_presses * b_y) ) / a_y.to_f  

  return 0 if b_presses.to_i != b_presses || a_presses.to_i != a_presses
  return 0 if b_presses < 0 || a_presses < 0
  return 0 if offset == 0 && (b_presses > MAX_PRESSES || a_presses > MAX_PRESSES)

  # floating point precision issues? Adding this line gets the right answer, so... 
  return 0 if a_presses != a_presses_2

  tokens = PRESS_A * a_presses + PRESS_B * b_presses
  
  return tokens.to_i
end

MAX_PRESSES = 100

tokens = 0

@machines.each do | machine |
  tokens += play(machine)
end

puts "PART 1: #{tokens}"

OFFSET = 10000000000000

tokens = 0

@machines.each do | machine |
  tokens += play(machine, OFFSET)
end

puts "PART 2: #{tokens}"

