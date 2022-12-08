input_file = "day-07-input.txt"

class Tree
  attr_accessor :children, :size, :name, :parent

  def initialize(name, size, parent)
    @name = name
    @size = size
    @children = []
    @parent = parent
  end

  def find_child(name)
    self.children.each do | child |
      return child if child.name == name
    end
  end
end

@top_level = Tree.new("/", 0, nil)

@work_dir = @top_level

def generate_file_structure(input_file)
  File.open(input_file).each do |line|
    line = line.chomp
    if line =~ /^\$/
      command = line.split(/\s/)
      if command[1] == 'cd'
        case command[2]
        when '..'
          @work_dir = @work_dir.parent unless @work_dir == @top_level
        when '/'
          @work_dir = @top_level
        else
          @work_dir = @work_dir.find_child(command[2])
        end
      end
    elsif line =~ /^dir/
      dir = line.split(/\s/).last
      @work_dir.children << Tree.new(dir, 0, @work_dir)
    else
      size, filename = line.split(/\s/)
      @work_dir.children << Tree.new(filename, size.to_i, @work_dir)
      update_sizes(@work_dir, size.to_i)      
    end
  end
end

def update_sizes(work_dir, size)
  work_dir.size += size
  unless work_dir == @top_level
    update_sizes(work_dir.parent, size)
  end
end

generate_file_structure(input_file)

@running_total = 0

def folder_sizes(work_dir)
  work_dir.children.each do | child |
    next unless child.children.size > 0 # not a directory
    @running_total += child.size if child.size <= 100_000
    @sizes << child.size
    folder_sizes(child)
  end
end

@sizes = []

folder_sizes(@top_level)
puts "Part 1: #{@running_total}"

total_space = 70_000_000
free_space_needed = 30_000_000

def find_folder_to_delete(total_space, free_space_needed)
  free_space = total_space - @top_level.size
  space_to_free_up = free_space_needed - free_space

  @sizes = @sizes.sort
  @sizes.each do | size |
    return size if size >= space_to_free_up
  end
end

puts "Part 2: #{find_folder_to_delete(total_space, free_space_needed)}"
  



