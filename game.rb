# Author: Chin Ning Ng
# Date: 17 March 2026
# This is the main file to run the game. It reads the board configuration and rolls from JSON files, initializes the game, and starts it.

require 'json'

# Run the game
board_file = "board.json"

["rolls_1.json", "rolls_2.json"].each do |rolls_file|
  puts "-----------------------------"
  puts "Game with rolls file: #{rolls_file}"
  puts "-----------------------------"

  game = Game.new(board_file, rolls_file)
  game.play
end