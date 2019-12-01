INPUT = 990_941.freeze

class RecipeGrid
  def initialize(initial)
    @recipes = initial
    @elves_positions = [0, 1]
  end

  def combine_and_terminate_after(terminate_after)
    terminate_after += 10 # we need 10 more to evaluate

    while @recipes.count < terminate_after
      combine!
    end

    @recipes[(terminate_after - 10)...terminate_after].map(&:to_s).join
  end

  def combine_and_terminate_with(terminate_with)
    terminate_with = terminate_with.chars.map(&:to_i)
    cache = []
    (0..Float::INFINITY).step do |i|
      new_combined = combine!
      (cache << new_combined).flatten!

      cache.shift if cache[0] == 1 && cache[1] == terminate_with[0]
      cache = [new_combined[1]] if new_combined[0] == 1 && terminate_with[0] == new_combined[1]

      unless cache[0...terminate_with.length] == terminate_with[0...cache.length]
        cache = []
      end

      if cache[0...terminate_with.length] == terminate_with
        return @recipes.count -
               terminate_with.length -
               (cache.length > terminate_with.length ? 1 : 0)
      end
    end
  end

  private

  def combine!
    current_recipes_sum = @elves_positions.map { |pos| @recipes[pos] }.sum

    @recipes << 1 if current_recipes_sum >= 10
    @recipes << current_recipes_sum % 10

    @elves_positions.map!.with_index do |pos, index|
      (1 + pos + @recipes[pos]) % @recipes.size
    end

    current_recipes_sum >= 10 ? [1, current_recipes_sum % 10] : [current_recipes_sum % 10]
  end
end

r = RecipeGrid.new([3, 7])
puts "Solution 14a: #{r.combine_and_terminate_after(INPUT)}"

r = RecipeGrid.new([3, 7])
# puts "Solution 14b: #{r.combine_and_terminate_with('59414'.to_s).to_i}"
puts "Solution 14b: #{r.combine_and_terminate_with(INPUT.to_s).to_i}"