# frozen_string_literal: true
require 'pry-byebug'

class Game
  def initialize(one = create_player, two = create_player, board = Board.new)
    @player_one = one
    @player_two = two
    @turn = 0
    @gamestate = 'not_started'
    @gameboard = board
  end

  def self.create_player
    puts "Welcome! What is your name?"
    name = gets.chomp
    puts "Welcome #{name}, what will be your token?"
    token = token_check(gets.chomp)
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

  def play_game()
    loop do
      break if @gameboard.game_end?(@player_one.token, @player_two.token)
      
    end
    win_message(@gamestate, @turn)
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

class Player
  attr_reader :name, :token

  def initialize(name, token)
    @name = name
    @token = token
  end
end

class Board
  def initialize
    @board = Array.new(7) { Array.new(6) }
  end

  def game_end?(token_one, token_two)
  end

  def place_token(token, col)
    return 'col_full' unless @board[col][5].nil?

    idx = @board[col].find_index { |x| x.nil? }
    @board[col][idx] = token
    nil
  end
end
# game = Game.new