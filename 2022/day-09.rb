input_file = "day-09-input.txt"

def tail_x 
  @positions[-1][:x]
end

def tail_y
  @positions[-1][:y]
end

def process_input(input_file, knots)
  @positions = Array.new(knots+1){{:x => 0, :y => 0}}

  @tail_visited = {}
  @tail_visited[tail_x] = {}
  @tail_visited[tail_x][tail_y] = 1

  File.open(input_file).each do |line|
    direction, movement = line.chomp.split(' ')

    count = 0
    while count < movement.to_i    
      case direction
      when "D"
        @positions[0][:x] -= 1
      when "U"
        @positions[0][:x] += 1
      when "L"
        @positions[0][:y] -= 1
      when "R"
        @positions[0][:y] += 1
      end
      
      (1..knots).each do | n |
        distance = Math.sqrt((@positions[n][:x] - @positions[n-1][:x])**2 + (@positions[n][:y] - @positions[n-1][:y])**2)
        
        if distance > Math.sqrt(2)
          @positions[n][:x] += 1 if @positions[n-1][:x] > @positions[n][:x] # R
          @positions[n][:x] -= 1 if @positions[n-1][:x] < @positions[n][:x] # L
          @positions[n][:y] += 1 if @positions[n-1][:y] > @positions[n][:y] # U
          @positions[n][:y] -= 1 if @positions[n-1][:y] < @positions[n][:y] # D
        end
      end
      
      @tail_visited[tail_x] ||= {}
      @tail_visited[tail_x][tail_y] = 1
      
      count += 1
    end
  end

  visited = @tail_visited.values.map(&:values).inject(&:+).sum
end

knots = 1

puts "Part 1: #{process_input(input_file, knots)}"

knots = 9

puts "Part 2: #{process_input(input_file, knots)}"

