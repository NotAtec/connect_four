# frozen_string_literal: true

require 'pry-byebug'

# Class containing all savable logic & methods for playing
class Game
  attr_writer :gamestate

  def initialize(one = Game.create_player, two = Game.create_player, board = Board.new)
    @player_one = one
    @player_two = two
    @turn = 0
    @gamestate = 'not_started'
    @gameboard = board
  end

  def self.create_player
    puts 'Welcome! What is your name?'
    name = gets.chomp
    puts "Welcome #{name}, what will be your token?"
    token = token_check(gets.chomp) while token.nil?
    Player.new(name, token)
  end

  def self.token_check(input)
    return input.upcase if input.match(/[A-Za-z]{1}/) && input.length == 1

    if input.length > 1
      puts 'Please input only 1 character'
    else
      puts 'Please input a letter (A-Z)'
    end
    nil
  end

  def play_game
    loop do
      val = @gameboard.game_end?(@player_one.token, @player_two.token, self)
      if val
        # @gamestate = val
        break
      end

      player = @turn.even? ? @player_one : @player_two
      input = col_input(player.name)
      @gameboard.place_token(player.token, input)
      # if place_token returns 'col_full' -> Get input again
      @turn += 1
      @gameboard.show_board
    end

    win_message(@gamestate, @turn)
  end

  def col_input(name)
    puts "#{name.upcase}, in which column will you place your next token?"
    input = col_check(gets.chomp) while input.nil?
    input
  end

  def col_check(input)
    return input if input.match(/[0-6]{1}/) && input.length == 1

    if input.length > 1
      puts 'Please input only 1 character'
    else
      puts 'Please input a number between 0 - 6'
    end
    nil
  end

  def win_message(state, turns)
    if state == 'tie'
      puts "It's a Tie!"
    elsif turns == 7 || turns == 8
      puts "Congrats #{state}! You won with a perfect game!"
    else
      puts "Congrats #{state}! You won!"
    end
  end
end

# Contains info for each player
class Player
  attr_reader :name, :token

  def initialize(name, token)
    @name = name
    @token = token
  end
end

# Contains info for the playable board and methods regarding it
class Board
  def initialize
    @board = Array.new(7) { Array.new(6) }
  end

  def game_end?(token_one, token_two, game)
    winner = four_in_row(token_one, token_two, @board) ||
             four_in_row(token_one, token_two, @board.transpose)  ||
             four_in_row(token_one, token_two, diagonals(@board)) ||
             four_in_row(token_one, token_two, antediagonals(@board))

    case winner
    when token_one
      'one'
    when token_two
      'two'
    else
      false
    end
  end

  def place_token(token, col)
    return 'col_full' unless @board[col][5].nil?

    idx = @board[col].find_index(&:nil?)
    @board[col][idx] = token
    nil
  end

  def show_board
    puts '| 0 | 1 | 2 | 3 | 4 | 5 | 6 |'
    puts '----------------------------'
    rows = setup_display
    strings = setup_strings(rows)
    strings.each { |s| puts s }
    puts '----------------------------'
  end

  private

  def four_in_row(one, two, rows)
    rows.each do |row|
      row.each_cons(4) do |set|
        return set[0] if set.all? { |x| x == one || x == two } && !set[0].nil?
      end
    end
    false
  end

  def diagonals(board)
    (0..board.size-4).map do |i|
      (0..board.size-1-i).map { |j| board[i+j][j] }
    end.concat((1..board.first.size-4).map do |j|
      (0..board.size-j-1).map { |i| board[i][j+i] }
    end)
  end

  def antediagonals(board)
    diags = [[[0, 2], [1, 3], [2, 4], [3, 5]],
             [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]],
             [[0, 0], [1, 1], [2, 2], [3, 3], [4, 4], [5, 5]],
             [[1, 0], [2, 1], [3, 2], [4, 3], [5, 4], [6, 5]],
             [[2, 0], [3, 1], [4, 2], [5, 3], [6, 4]],
             [[3, 0], [4, 1], [5, 2], [6, 3]]]
    rows = []

    diags.each do |diag|
      row = []
      diag.each do |location|
        row << board[location[0]][location[1]]
      end
      rows << row
    end
    rows
  end
  
  def setup_display
    rows = [[], [], [], [], [], []]
    @board.reverse_each do |col|
      col.reverse_each.with_index do |val, idx|
        rows[idx] << val
      end
    end
    rows
  end

  def setup_strings(rows)
    strings = []
    rows.each do |row|
      string = '|'
      row.each do |cell|
        if cell.nil?
          string << '   '
        else
          string << " #{cell} "
        end
        string << '|'
      end
      strings << string
    end
    strings
  end
end
# game = Game.new
