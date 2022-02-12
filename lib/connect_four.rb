# frozen_string_literal: true

require 'pry-byebug'

# Class containing all savable logic & methods for playing
class Game
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
      break if @gameboard.game_end?(@player_one.token, @player_two.token)

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
    @rows = Array.new(6) { Array.new(7) }
  end

  def game_end?(token_one, token_two); end

  def place_token(token, col)
    return 'col_full' unless @board[col][5].nil?

    idx = @board[col].find_index(&:nil?)
    @board[col][idx] = token
    @rows[idx][col] = token
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
