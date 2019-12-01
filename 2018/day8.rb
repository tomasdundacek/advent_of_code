NUMBERS = File.read('data/day8.txt').split.map(&:to_i)

def get_nodes(numbers)
  number_of_children = numbers.shift
  metadata_count = numbers.shift

  children = Array.new(number_of_children) do
    get_nodes(numbers)
  end

  metadata = numbers.shift(metadata_count)
  {
    metadata: metadata,
    children: children
  }
end

def metadata_sum(node)
  metadata = [node[:metadata]] + node[:children].map { |c| metadata_sum(c) }
  metadata.flatten.reduce(:+)
end

def node_value(node)
  return 0 if node.nil?

  if node[:children].empty?
    node[:metadata].reduce(:+)
  else
    node[:metadata].
      map { |m| m - 1 }.
      map { |i| node_value(node[:children][i]) }.
      reduce(:+)
  end
end

puts "Solution 8a: #{metadata_sum(get_nodes(NUMBERS.dup))}"
puts "Solution 8b: #{node_value(get_nodes(NUMBERS))}"
