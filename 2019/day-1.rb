total_fuel = 0

def calculate_fuel(total, x)
  fuel = (x/3).floor - 2
  if fuel > 0
    total += fuel
    total = calculate_fuel(total, fuel)
    return total
  end
  return total
end

File.open('day-1-input.txt').each do |line|
  mass = line.chomp
  fuel = calculate_fuel(0, mass.to_i)
  puts fuel
  total_fuel += fuel
end

puts total_fuel
