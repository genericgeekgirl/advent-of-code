width = 25
height = 6

$digits_in_layer = width * height

image_layers = File.read("day-8-input.txt").chomp.chars.each_slice($digits_in_layer).map(&:join)

def check_corruption(image_layers)

  zeroes = []

  image_layers.each do | layer |
    digits = layer.split('').map(&:to_i)
    zeroes << digits.count(0)
  end

  layer_index = zeroes.index(zeroes.min)
  layer = image_layers[layer_index].split('').map(&:to_i)
  return layer.count(1) * layer.count(2)
end

#solution = check_corruption(image_layers)
#puts solution

def get_value_for_position(array)
  first_black_pixel = array.index(0) || $digits_in_layer
  first_white_pixel = array.index(1) || $digits_in_layer

  color_at_position = (first_black_pixel < first_white_pixel) ? " " : "+"

  if first_black_pixel == $digits_in_layer and first_white_pixel == $digits_in_layer
    color_at_position = 2
  end

  return color_at_position
end

final_image_array = []

for i in 0..$digits_in_layer-1 do
  position_array = []
  image_layers.each do | layer |
    position_array << layer[i].to_i
  end
  final_image_array << get_value_for_position(position_array)
end

rows = final_image_array.join('').chars.each_slice(width).map(&:join)

puts rows
