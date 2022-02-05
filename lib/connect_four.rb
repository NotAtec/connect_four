# frozen_string_literal: true
require 'pry-byebug'

class Game
  def initialize(one = create_player, two = create_player)
    @player_one = one
    @player_two = two
    @turn = 0
    @gamestate = 'not_started'
    @gameboard = Board.new
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
    @board = Array.new(7, Array.new(6))
  end

  def game_won?(token_one, token_two)
  end
end
# game = Game.new