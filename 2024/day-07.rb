INPUT_FILE = "day-07-input.txt"

input = []

File.readlines(INPUT_FILE, chomp: true).each do | line |
  value, number_string = line.split(": ")
  numbers = number_string.split(' ')
  input << [value.to_i, numbers]
end

def build_equations(numbers, operators)
  operator_number_combinations = {}
  numbers[1..-1].each do | number |
    product = operators.product([number])
    operator_number_combinations[number] = product.map { | combination | combination.join('') }
  end

  possibilities = [numbers[0]]
  numbers[1..-1].each do | number |
    product = possibilities.product(operator_number_combinations[number])
    possibilities = product.map { | combination | combination.join('') }
  end

  return possibilities
end

def has_valid_equation(value, equations)
  equations.each do | string |
    numbers = string.split(/[^0-9]+/).map(&:to_i)
    operators = string.split(/\d+/)

    evaluation = 0

    operators.each do | operator |
      number = numbers.shift
      
      case operator
      when '+'
        evaluation += number
      when '*'
        evaluation *= number
      when '||'
        evaluation = (evaluation.to_s + number.to_s).to_i
      else
        evaluation = number
      end

      break if evaluation > value and !numbers.include?(0)
    end

    return true if evaluation == value
  end
  
  return false
end

sum = 0
operators = ["+", "*"]

input_equations = {}
invalid_input = []

input.each do | i |
  value, numbers = i
  input_equations[i] = equations = build_equations(numbers, operators)
  if has_valid_equation(value, equations)
    sum += value
  else
    invalid_input << i
  end
end

puts "PART 1: #{sum}"

def add_operator(equation, new_operator)
  numbers = equation.split(/[^0-9]+/)
  operators = equation.split(/\d+/).delete_if { | operator | operator.empty? }
  
  options = operators.map { | operator | [operator, new_operator] }
  
  combinations = options.pop
  options.each do | operators |
    product = combinations.product(operators)
    combinations = product.map { | combination | combination.join(',') }
  end
  combinations = combinations.uniq.delete_if { | combination | !combination.include?(new_operator) }
  
  new_equations = []  
  combinations.each do | operators |
    equation_string = numbers[0].to_s + operators.split(',').zip(numbers[1..-1]).join('')
    new_equations << equation_string
  end
  
  return new_equations
end

new_operator = "||"
operators << new_operator

invalid_input.each do | i |
  value, numbers = i
  equations = build_equations(numbers, operators) - input_equations[i]
#  equations = input_equations[i].map { | equation | add_operator(equation, new_operator) }.flatten
  sum += value if has_valid_equation(value, equations)
end

puts "PART 2: #{sum}"

# PART 1: 4998764814652
# PART 2: 37598910447546
