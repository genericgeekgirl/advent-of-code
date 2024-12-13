
input = "183564-657474"

range_low, range_high = input.split('-').map(&:to_i)

valid_passwords = 0

#range_low = 588889
#range_high = 588889

for n in range_low..range_high do
  duplicate_found = false
  not_decreasing = true
  number_array = n.to_s.split('').map(&:to_i)
  for i in 0..number_array.length-2 do
    if i == 0
      if number_array[i] == number_array[i+1] and number_array[i] != number_array[i+2]
        duplicate_found = true
      end
    else
      if number_array[i] == number_array[i+1] and number_array[i] != number_array[i+2] and number_array[i] != number_array[i-1]
        duplicate_found = true
      end
    end
    not_decreasing = false if number_array[i] > number_array[i+1]
  end
  valid_passwords += 1 if duplicate_found and not_decreasing
end

puts valid_passwords
