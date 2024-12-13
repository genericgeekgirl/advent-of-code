INPUT_FILE = "day-05-input.txt"

rules = {}

orderings = []

File.readlines(INPUT_FILE, chomp: true).each do | line |
  next if line.empty?
  
  if match = line.match(/(\d+)\|(\d+)/)
    before, after = match.captures.map(&:to_i)
    rules[before] ||= []
    rules[before] << after
  else
    orderings << line.split(',').map(&:to_i)
  end
end

sum = 0
fixed_sum = 0

orderings.each do | ordering |
  rules_that_apply = {}
  last_page = nil
  
  ordering.each do | number |
    if rules[number]
      rules_that_apply[number] = rules[number] & ordering
    else
      last_page = number
    end
  end

  ordered_rules = rules_that_apply.sort_by { | _k, pages | pages.count }.to_h
  ordered_pages = ordered_rules.keys.reverse

  lookup = {}
  ordered_pages.each_with_index do | page, index |
    lookup[page] = index
  end

  if !last_page.nil?
    lookup[last_page] = lookup.length
  end

  sorted_ordering = []
  ordering.sort_by do | page |
    sorted_ordering[lookup.fetch(page)] = page
  end
  sorted_ordering = sorted_ordering.compact

  if ordering == sorted_ordering
    sum += ordering[ordering.length/2]
  else
    fixed_sum += sorted_ordering[sorted_ordering.length/2]
  end
end
  
puts "PART 1: #{sum}"
puts "PART 2: #{fixed_sum}"
