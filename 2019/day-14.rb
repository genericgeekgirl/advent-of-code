filename = 'day-14-input.txt'

def process_input(filename)
  File.open(filename).each do |line|
    requirements, result = line.chomp.split(' => ')
    amount, result = result.split(' ')
    $quantity_produced[result] = amount.to_i
    $reactions[result] = {}
    requirements = requirements.split(', ')
    requirements.each do | requirement |
      amount, requirement = requirement.split(' ')
      $reactions[result][requirement] = amount.to_i
    end
  end
end

def find_chain_length(result, start = result)
  $chain_length[start] = 0 if $chain_length[start].nil?
  $reactions[result].each do | requirement, amount |
    $chain_length[start] += 1    
    return if requirement == 'ORE'
    find_chain_length(requirement, start)
  end
  return
end

def calculate_leftover_material(result, quantity_produced, quantity_needed)
  $leftover_material[result] = 0 if $leftover_material[result].nil?
  
  reactions_needed = (quantity_needed.to_f/quantity_produced.to_f).ceil 
  
  if $leftover_material[result] >= quantity_produced
    reactions_needed -= $leftover_material[result]/quantity_produced 
    quantity_needed -= $leftover_material[result] - $leftover_material[result] % quantity_produced
    $leftover_material[result] = $leftover_material[result] % quantity_produced
  end

  leftover_material = (quantity_produced * reactions_needed) - quantity_needed  
  $leftover_material[result] += leftover_material  

  return reactions_needed
end

def break_down_results(result, quantity_needed)
  requirements = $reactions[result]

  if requirements.keys == ['ORE']
    calculate_ore_needed(result, quantity_needed)
    return
  end

  quantity_produced = $quantity_produced[result]
  
  reactions_needed = calculate_leftover_material(result, quantity_produced, quantity_needed)
  
  requirements.each do | requirement, amount |
    next if requirement == 'ORE'
    $quantity_needed[requirement] = 0  if $quantity_needed[requirement].nil?
    $quantity_needed[requirement] += reactions_needed * amount    
  end
end

def calculate_ore_needed(result, quantity_needed)
  quantity_produced = $quantity_produced[result]
  
  reactions_needed = calculate_leftover_material(result, quantity_produced, quantity_needed)
    
  ore_needed = $reactions[result]['ORE']
  $ore_needed_for_fuel += reactions_needed * ore_needed
end

$quantity_produced = {}
$reactions = {}

process_input(filename)

$chain_length = {}

$reactions.keys.each do | result |
  find_chain_length(result)
end

results = $chain_length.sort_by{ |key, value| -value }.map{ | array | array[0] }

$quantity_needed = {'FUEL' => 1}

$ore_needed_for_fuel = 0

$leftover_material = {}

results.each do | result |
  break_down_results(result, $quantity_needed[result])
  $quantity_needed.delete(result)
end

def run_simulation(fuel_to_generate, results)
  $quantity_needed = {'FUEL' => fuel_to_generate}

  $ore_needed_for_fuel = 0

  $leftover_material = {}

  results.each do | result |
    break_down_results(result, $quantity_needed[result])
    $quantity_needed.delete(result)
  end

  remaining_ore = $ore_available - $ore_needed_for_fuel

  return remaining_ore
end

$ore_available = 1000000000000

ore_needed_for_initial_fuel = $ore_needed_for_fuel

minimum_fuel = ($ore_available.to_f/ore_needed_for_initial_fuel.to_f).ceil

high_bound = minimum_fuel
low_bound = 0

last_offset = 0

while true
  offset = ((high_bound+low_bound).to_f/2).floor
  fuel_to_generate = minimum_fuel + offset
  remaining_ore = run_simulation(fuel_to_generate, results)

  if remaining_ore == 0
    break
  elsif remaining_ore < 0
    high_bound = offset
  elsif last_offset - offset == 1
    break
  else
    low_bound = offset
  end

  last_offset = offset
end

puts fuel_to_generate
