data = File.read('data/day17a.txt').lines.map(&:chomp)

data.map do |line|
  parts = line.split(', ').sort.map do |part|
    part[2..-1].split('..').map(&:to_i)
  end


end

SPRING = [500, 0]