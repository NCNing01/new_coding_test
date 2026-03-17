# Author: Chin Ning Ng
# Date: 17 March 2026
# This is the main file to run the game. It reads the board configuration and rolls from JSON files, initializes the game, and starts it.

require 'json'

class Player
  # This class represents a player in the game, with attributes for name, money, position on the board, and bankruptcy status.
  # Giving the accessor methods allows to  read and modify these attributes throughout the game.
  attr_accessor :name, :money, :position, :bankrupt

  # Start each player with a name, initial money of 16, starting position of 0, and not bankrupt.
  def initialize(name)
    @name = name
    @money = 16
    @position = 0
    @bankrupt = false
  end
end

class Game

  def initialize(board_file, rolls_file)
    # Read the board and rolls from JSON files
    @board = JSON.parse(File.read(board_file))
    @rolls = JSON.parse(File.read(rolls_file))
    @board_size = @board.length

    # Create new players with their names
    @players = [
      Player.new("Peter"),
      Player.new("Billy"),
      Player.new("Charlotte"),
      Player.new("Sweedal")
    ]

    #add the ownership field to each property space on the board
    @board.each do |space|
      if space["type"] == "property"
        space["owner"] = nil
      end
    end

    build_color_groups
  end

  def build_color_groups
    # Build a hash to group properties by their color.
    @color_groups = {}

    # This will help in calculating rent based on the number of properties owned in the same color group.
    @board.each do |space|
      if space["type"] == "property"
        color = space["color"]
        @color_groups[color] ||= [] # Check if the color group already exists, if not initialize it as an empty array
        @color_groups[color] << space
      end
    end

end

# Run the game
board_file = "board.json"

["rolls_1.json", "rolls_2.json"].each do |rolls_file|
  puts "-----------------------------"
  puts "Game with rolls file: #{rolls_file}"
  puts "-----------------------------"

  game = Game.new(board_file, rolls_file)
  game.play
end