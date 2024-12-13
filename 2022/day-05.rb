file = 'day-05-input.txt'

@stacks = {}
@count = 0

def process_move(line, part)
  matches = line.match(/^move\s(?<count>\d+)\sfrom\s(?<from>\d+)\sto\s(?<to>\d+)/)

  from_stack = @stacks[matches[:from]]
  to_stack = @stacks[matches[:to]]
  count_to_move = matches[:count].to_i
  
  blocks = from_stack.shift(count_to_move)
  if part == 2
    blocks = blocks.reverse
  end
  
  blocks.each do | block |
    to_stack.unshift(block)
  end
end

def count_stacks(line)
  @count = line.chomp.split(/\s+/).last.to_i
  (1..@count).each do | n |
    @stacks[n.to_s] = []
  end
end

@rows = []

def process_row(line)
  @rows << line.chomp.gsub(/(...)./, '\1_').gsub(/\s{3}/, "[]").split('_')
end

def build_stacks
  @rows.each do | row |
    (1..@count).each do | n |
      box = row[n-1].gsub(/[\[\]]/, "")
      @stacks[n.to_s] << box unless box.empty?
    end
  end
end

def find_top_blocks
  top_blocks = []
  @stacks.keys.sort.each do | key |
    top_blocks << @stacks[key].first
  end
  top_blocks.join("")
end

def process_input(file, part)
  File.open(file).each do |line|
    next if line.chomp.empty?
    if line =~ /move/
      process_move(line, part)
    elsif line =~ /\d/
      count_stacks(line)
      build_stacks
    else
      process_row(line)
    end
  end
  find_top_blocks
end

puts "Part 1: #{process_input(file, 1)}"
 
puts "Part 2: #{process_input(file, 2)}"

