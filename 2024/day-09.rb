INPUT_FILE = "day-09-input.txt"
 
@free_space = {}
@files = {}

def process_data
  index = 0
  is_file = true
  file_id = 0
  
  File.open(INPUT_FILE) do |f|
    f.each_char do | c |
      n = c.to_i
      
      if is_file
        @files[index] = [file_id, n]
      else
        @free_space[index] = n
      end
    
      is_file = !is_file
      file_id += 1 if !is_file
      index += n
    end
  end

  return index
end

def chunk_up_files
  index = i = 0
  files = []
  chunked_files = {}
  
  while i < LENGTH
    if @files.has_key?(i)
      id, blocks = @files[i]
      files += [id] * blocks
      i += blocks
    elsif @free_space.has_key?(i)
      blocks = @free_space[i]
      chunked_files[index] = files
      files = []
      i += blocks
      index = i
    end
    chunked_files[index] = files
  end
  
  return chunked_files
end

def string_representation(array, chunked = false)
  representation = []

  (0..LENGTH-1).each do | i |
    if array.has_key?(i)
      if chunked
        representation += array[i]
      else
        index, blocks = array[i]
        representation += [index] * blocks
      end
    elsif @free_space.has_key?(i)
      blocks = @free_space[i]
      representation += ["."] * blocks
    end
  end
  
  return representation.join(",")
end

LENGTH = process_data

@chunked_files = chunk_up_files

def compact_blocks
  free_space = @free_space.map { | _i, blocks | blocks }.sum
  
  files_to_move = string_representation(@chunked_files, true).split(',').last(free_space).reverse - ["."]

  index = LENGTH - free_space
  chunked_indices = @chunked_files.keys.sort

  (0..chunked_indices.length-1).each do | i |
    files_index = chunked_indices[i]
    if files_index >= index
      (i..chunked_indices.length-1).each do | j |
        @chunked_files.delete(chunked_indices[j])
      end
      
      if files_index > index
        previous_index = chunked_indices[i-1]
        files= @chunked_files[previous_index]
        end_point = files.length - (files_index - index)
        @chunked_files[previous_index] = files[0..end_point]
      end
      break
    end
  end

  @free_space.each do | index, blocks |
    files = files_to_move.shift(blocks)
    @chunked_files[index] = files
  end
end

def compact_files
  @files.sort.reverse.each do | file_index, file |
    id, file_blocks = file
    @free_space.sort.each do | fs_index, fs_blocks |
      break if fs_index > file_index
      next if file_blocks > fs_blocks
      @files.delete(file_index)
      @free_space.delete(fs_index)
      @files[fs_index] = [id, file_blocks]
      @free_space[file_index] = file_blocks
      if file_blocks < fs_blocks
        @free_space[fs_index + file_blocks] = fs_blocks - file_blocks
      end
      break
    end
  end
end

def calculate_checksum(string)
  return string.split(',').each_with_index.map { | file, index | index * file.to_i }.sum
end

compact_blocks
string = string_representation(@chunked_files, true)
puts "PART 1: #{calculate_checksum(string)}"

compact_files
string = string_representation(@files)
puts "PART 2: #{calculate_checksum(string)}"


