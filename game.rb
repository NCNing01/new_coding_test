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

  def play
    # Main game loop that iterates through the rolls and processes each player's turn until all rolls are exhausted or a player goes bankrupt.
    turn = 0

    @rolls.each do |roll|
      player = @players[turn % @players.length] # Determine the current player based on the turn number and total players

      move_player(player, roll)

      space = @board[player.position]

      handle_space(player, space)

      if player.money < 0
        player.bankrupt = true
        puts "#{player.name} has gone bankrupt!"
        break # End the game if a player goes bankrupt
      end

      turn += 1
    end
    
    print_results
  end

  def move_player(player, roll)
    # Move the player based on the roll and handle wrap-around using modulo operator. 
    old_position = player.position
    new_position = (old_position + roll) % @board_size # Calculate new position with wrap-around using modulo operator

    if new_position < old_position
      player.money += 1 # Collect $1 for passing the start position
    end

    player.position = new_position
  end

  def handle_space(player, space)
    # Handle the logic for when a player lands on a space. 
    if space["type"] == "property"
      if space["owner"].nil?
        # If the property is unowned, the player must buy it.
        buy_property(player, space)

      elsif space["owner"] != player.name
        # If the property is owned by another player, the current player must pay rent.
        pay_property(player, space)

      end
    else
      return
    end
  end

  def buy_property(player, space)
    # Handle the logic for buying a property. 
    price = space["price"]

    player.money -= price
    space["owner"] = player.name 
    
  end

  def pay_property(player, space)
    # Handle the logic for paying rent on a property. 
    owner_name = space["owner"]
    color = space["color"]
    rent = space["rent"]
    owner = @players.find { |p| p.name == owner_name } 

    if owns_same_color_group?(owner, color)
      rent *= 2 # If the owner owns all properties of the same color, rent is doubled
    end

    player.money -= rent
    owner.money += rent 
    
  end

  def owns_same_color_group?(owner, color)
    # Check if the owner owns all properties of the same color group. 
    @color_groups[color].all? { |property| property["owner"] == owner.name }
  end

  def print_results
    # Print the final results of the game, showing each player's name, money, and bankruptcy status.
    winner = @players.max_by { |player| player.money }
    
    puts "Final Results:"
    puts "Winner: #{winner.name} with $#{winner.money}"
    
    @players.each do |player|
      space_name = @board[player.position]["name"]

      puts "#{player.name}:"
      puts "  Money: $#{player.money}"
      puts "  Position: #{space_name}"
      puts "  Bankrupt: #{player.bankrupt ? 'Yes' : 'No'}
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