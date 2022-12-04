running_score_part_1 = 0

@outcome_score = { "lost" => 0, "draw" => 3, "won" => 6 }
@play_score    = { "rock" => 1, "paper" => 2, "scissors" => 3 }

@moves = { "A" => "rock", "B" => "paper", "C" => "scissors", "X" => "rock", "Y" => "paper", "Z" => "scissors" }
@x_beats_y = { "rock" => "scissors", "paper" => "rock", "scissors" => "paper" }

def part_1_calculate_score(opponent, myself)
  my_move = @moves[myself]
  their_move = @moves[opponent]

  score = @play_score[my_move]
  
  if my_move == their_move
    score += @outcome_score["draw"]
  elsif their_move == @x_beats_y[my_move]
    score += @outcome_score["won"]
  else
    score += @outcome_score["lost"]
  end
  
  return score
end

File.open('day-02-input.txt').each do |line|
  opponent, myself = line.chomp.split(' ')
  running_score_part_1 += part_1_calculate_score(opponent, myself)
end

puts "Part 1: #{running_score_part_1}"

@outcomes = { "X" => "lost", "Y" => "draw", "Z" => "won" }

def part_2_calculate_score(opponent, outcome)
  their_move = @moves[opponent]
  outcome = @outcomes[outcome]

  if outcome == "won"
    my_move = @x_beats_y.key(their_move)
  elsif outcome == "draw"
    my_move = their_move
  else # outcome == "lost"
    my_move = @x_beats_y[their_move] 
  end

  score = @outcome_score[outcome]
  score += @play_score[my_move]
  return score
end

running_score_part_2 = 0

File.open('day-02-input.txt').each do |line|
  opponent, outcome = line.chomp.split(' ')
  running_score_part_2 += part_2_calculate_score(opponent, outcome)
end

puts "Part 1: #{running_score_part_2}"
