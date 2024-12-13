INPUT_FILE = "day-02-input.txt"

safe_records = 0
modified_safe_records = 0

def ordered(report)
  report == report.sort || report == report.sort.reverse
end

def safe_difference(report)
  (0..report.length-2).each do | i |
    return false unless (report[i].to_i - report[i+1].to_i).abs <= 3
  end
  
  true
end

def check_indices(report, indices)
  indices.each do | i |
    report_copy = report.dup
    report_copy.delete_at(i)
    return true if first_pass(report_copy)
  end
  
  false
end

def first_pass(report)
  (report == report.uniq) && ordered(report) && safe_difference(report)
end  

def modified_unique(report)
  return nil if report == report.uniq
  return false if report.uniq.size > report.size - 1

  # there's only one duplicate... find the wrong one
  duplicate = report.tally.sort_by {| _k, v| v}.to_h.keys.last
  indices = report.each_index.select{ |i| report[i] == duplicate}

  return check_indices(report, indices)
end

def modified_ordering(report)
  return nil if ordered(report)
  
  sorted = report.zip(report.sort).map { | a, b | a == b ? 0 : 1 }
  reverse_sorted = report.zip(report.sort.reverse).map { | a, b | a == b ? 0 : 1 }

  indices = []
  
  [sorted, reverse_sorted].each do | report_sorted |
    indices += report_sorted.each_index.select{ |i| report_sorted[i] == 1 }
  end

  return check_indices(report, indices)
end
    
def modified_safe_difference(report)
  return nil if safe_difference(report)
  
  indices = []
  
  (0..report.length-2).each do | i |
    difference = (report[i].to_i - report[i+1].to_i).abs
    next if difference <= 3
    indices = [i, i+1]
    break
  end

  return check_indices(report, indices)
end

def second_pass(report)
  unique = modified_unique(report)
  ordered = modified_ordering(report)
  safe_difference = modified_safe_difference(report)

  [unique, ordered, safe_difference].compact.include?(true)
end

File.readlines(INPUT_FILE, chomp: true).each do | line |  
  report = line.split(" ").map { | level | level.to_i }

  if first_pass(report)
    safe_records += 1
    next
  end

  if second_pass(report)
    modified_safe_records += 1
  end
end

puts "PART 1: #{safe_records}"
puts "PART 2: #{safe_records + modified_safe_records}"

