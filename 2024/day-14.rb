
SAMPLE = true

INPUT_FILE = SAMPLE ? "day-14-sample-input.txt" : "day-14-input.txt"

SECONDS = 100

HEIGHT = SAMPLE ? 7 : 103
WIDTH = SAMPLE ? 11 : 101

robots = []

File.foreach(INPUT_FILE) do | line |
  captures = line.match(/p=(\d+),(\d+)\sv=(-?\d+),(-?\d+)/).captures.map(&:to_i)
  position = captures[0..1]
  velocity = captures[2..3]
  robots << { position: position, velocity: velocity, starting: position }
end

def wrap(x, y)
  return [x, y]
end

def walk(position, velocity, seconds)
  x, y = position
  mod_x, mod_y = velocity
  
  while seconds > 0
    x += mod_x
    y += mod_y
    if x >= WIDTH || y >= HEIGHT
      x, y = wrap(x, y)
    end
    seconds -= 1
  end
  
  return [x, y]
end

(0..robots.length-1).each do | i |
  robot = robots[i]
  position = walk(robot[:position], robot[:velocity], SECONDS)
  robots[i][:position] = position
end

puts robots
