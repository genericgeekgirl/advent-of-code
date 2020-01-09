
def get_integer_by_mode(mode, i, offset, relative_base)
  case mode
  when 0 # positional mode
    integer = $intcode[$intcode[i+offset]] || 0
  when 1 # immediate mode
    integer = $intcode[i+offset] || 0
  when 2 # relative mode
    integer = $intcode[$intcode[i+offset] + relative_base] || 0
  end
  return integer
end

def get_position_by_mode(mode, i, offset, relative_base)
  case mode
  when 0 # positional mode
    position = $intcode[i+offset]
  when 1 # immediate mode
    puts "ERROR"
  when 2 # relative mode
    position = $intcode[i+offset] + relative_base
  end
  return position
end

def count_blocks
  num_blocks = 0
  $matrix.each do | row |
    num_blocks += row.count(2)
  end
  return num_blocks
end

def draw_grid
  $matrix.each do | row |
    row.each do | tile |
      case tile
      when 0
        print ' ' 
      when 1
        print '+'
      when 2
        print 'O'
      when 3
        print '_'
        $paddle_position = row.index(3)
      when 4
        print '*'
        $ball_position = row.index(4)
      end
    end
    puts ''
  end
end

$paddle_position = 0
$ball_position = 0

def get_input
  return -1 if $paddle_position > $ball_position
  return 1 if $paddle_position < $ball_position
  return 0
end

def update_matrix
  if $output_array[0] == -1 and $output_array[1] == 0
    $score = $output_array[2]
    puts "SCORE: #{$score}"
    if count_blocks == 0
      puts "YOU WIN!"
      exit
    end
  else
    while $output_array.length > 0
      array = $output_array.shift(3)
      x = array[0]
      y = array[1]
      tile = array[2]
      $matrix[y] = [] if $matrix[y].nil?
      $matrix[y][x] = tile
    end
  end
  $output_array = []
end

def intcode_computer
  i = 0
  relative_base = 0

  play_game = 0
  
  while i <= $intcode.length
    opcode = $intcode[i]

    modes = []
    
    if opcode.abs.to_s.length > 2
      opcode = opcode.to_s.reverse
      modes = opcode[2..-1].reverse.split('').map(&:to_i)
      opcode = opcode[0..1].reverse.to_i
    end

    mode1 = modes.length > 0 ? modes.pop : 0
    mode2 = modes.length > 0 ? modes.pop : 0
    mode3 = modes.length > 0 ? modes.pop : 0

    case opcode
    when 1 # addition
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      sum = integer1 + integer2
      $intcode[position] = sum
      i += 4
    when 2 # multiplication
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      product = integer1 * integer2
      $intcode[position] = product
      i += 4
    when 3 # input
      if play_game == 0
        update_matrix
        play_game = 1
      end
      draw_grid
      input = get_input
      position = get_position_by_mode(mode1, i, 1, relative_base)
      $intcode[position] = input
      i += 2
    when 4 # output 
      output = get_integer_by_mode(mode1, i, 1, relative_base)
      $output_array << output
      if play_game == 1 and $output_array.length == 3
        update_matrix
      end
      i += 2
    when 5 # jump-if-true
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      i = (integer1 != 0) ? integer2 : i+3
    when 6 # jump-if-false
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      i = (integer1 == 0) ? integer2 : i+3
    when 7 # less than
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      value = integer1 < integer2 ? 1 : 0
      $intcode[position] = value
      i += 4
    when 8 # equals
      integer1 = get_integer_by_mode(mode1, i, 1, relative_base)
      integer2 = get_integer_by_mode(mode2, i, 2, relative_base)
      position = get_position_by_mode(mode3, i, 3, relative_base)
      value = integer1 == integer2 ? 1 : 0
      $intcode[position] = value
      i += 4
    when 9 # update relative base
      adjustment = get_integer_by_mode(mode1, i, 1, relative_base)
      relative_base += adjustment
      i += 2
    when 99 # HALT
      puts "GAME OVER: #{$score}"
      break
    else
      puts "ERROR at position #{i}"
      break
    end
  end
end

$intcode = File.read("day-13-input.txt").chomp.split(',').map(&:to_i)
$intcode[0] = 2

$output_array = []
$matrix = []
$score = 0

intcode_computer()


