PLAYERS = 435
MARBLES = 71_184

class ElvesGame
  attr_accessor :board, :players, :scores, :marbles, :current_marble_index

  def initialize(players, marbles)
    # puts "Players: #{players}, marbles: #{marbles}"
    self.players              = players
    self.scores               = [0] * players
    self.marbles              = marbles
    self.current_marble_index = 0

    create_board!
  end

  def run!
    (1..marbles).each do |marble|
      current_player = marble % players

      # puts marble/marbles.to_f if marble % 5000 == 0 # progress debug for part 2 (takes super-long)
      score = place_marble!(marble)
      scores[current_player] += score
    end
    scores.max
  end

  private

  def create_board!
    self.board = [0]
  end

  def place_marble!(marble)
    if marble % 23 > 0
      self.current_marble_index = ((current_marble_index + 2) % (board.length + 1))
      if current_marble_index == 1
        board.append(marble)
      else
        board.insert(current_marble_index - 1, marble)
      end

      0
    else
      self.current_marble_index = (current_marble_index - 7) % board.length
      removed = board.delete_at(current_marble_index - 1)

      marble + removed
    end
  end
end

# ElvesGame.new(9, 25).run! # 32
# ElvesGame.new(10, 1618).run! # 8317
# ElvesGame.new(13, 7999).run! # 146373
# ElvesGame.new(17, 1104).run! # 2784
# ElvesGame.new(21, 6111).run! # 54718
# ElvesGame.new(30, 5807).run! # 37305
puts "Solution 9a: #{ElvesGame.new(PLAYERS, MARBLES).run!}"
puts "Solution 9b: #{ElvesGame.new(PLAYERS, MARBLES * 100).run!}"