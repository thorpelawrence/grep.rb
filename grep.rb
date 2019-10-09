require 'set'

def grep(pattern, flags, file_names)
  print_line_numbers = flags.include?("n")
  invert = flags.include?("v")
  match_entire_line = flags.include?("x")
  case_insensitive = flags.include?("i")
  file_names_only = flags.include?("l")

  search_pattern = pattern.dup
  search_pattern.downcase! if case_insensitive

  matching_files = Set.new
  matches = []
  file_names.each do |file_name|
    lines = IO.readlines(file_name)
    lines.each_with_index do |line, line_no|
      line.downcase! if case_insensitive
      is_match = false
      if line.include?(search_pattern)
        if match_entire_line
          is_match = line.chomp == search_pattern
        else
          is_match = true
        end
      end
      if (!invert && is_match) || (invert && !is_match)
        if print_line_numbers
          matches << "#{(line_no + 1).to_s.ljust(3)}| #{line}"
        else
          matches << line
        end
        matching_files.add(file_name)
      end
    end
  end
  if file_names_only
    matching_files.to_a
  else
    matches
  end
end

args = ARGV

if args.length < 2
  STDERR.puts "Usage: #{$0} [ pattern ] [-nlivx] [ file ... ]"
  exit 1
end

pattern = nil
flags = []
files = []
args.each_with_index do |arg, index|
  if index == 0 # first arg is always pattern
    pattern = arg
    next
  end
  if arg.start_with?("-")
    flag = arg[1..] # ignore the dash
    flags.concat(flag.split('')) # add adjacent flags without spaces as separate
  else
    files << arg
  end
end

matches = grep(pattern, flags, files)
puts matches
