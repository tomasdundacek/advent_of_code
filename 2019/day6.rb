data = File.read('data/day6.txt').lines.map(&:chomp)

# data = %w[COM)B B)C C)D D)E E)F B)G G)H D)I E)J J)K K)L] # 42 orbits - example for part 1
# data = %w[COM)B B)C C)D D)E E)F B)G G)H D)I E)J J)K K)L K)YOU I)SAN] # 4 orbital transfers - example for part 2

# Part 1
orbits = data.inject({}) do |memo, orbit|
  orbited, orbitee = orbit.split(')')

  memo[orbitee] = orbited
  memo
end

count = orbits.inject(0) do |memo, (key, _)|
  new_key = key

  while orbits[new_key]
    memo += 1
    new_key = orbits[new_key]
  end

  memo
end

puts "Part 1: #{count}"

# Part 2
# Find first common ancestor

def orbit_path(orbits, key)
  ary = []
  while orbits[key]
    ary << orbits[key]
    key = orbits[key]
  end

  ary
end

orbit_path_me = orbit_path(orbits, 'YOU')
orbit_path_santa = orbit_path(orbits, 'SAN')
common_ancestor = (orbit_path_me & orbit_path_santa).first
part2 = orbit_path_me.index(common_ancestor) + orbit_path_santa.index(common_ancestor)

puts "Part 2: #{part2}"
