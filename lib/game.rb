
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
      val = @gameboard.game_end(@player_one.token, @player_two.token)
      if val
        winner = @turn.even? ?  @player_two : @player_one
        @gamestate = winner
        break
      end
      
      @gameboard.show_board
      player = @turn.even? ? @player_one : @player_two
      input = col_input(player.name)
      @gameboard.place_token(player.token, input.to_i)
      # if place_token returns 'col_full' -> Get input again
      @turn += 1
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
    @gameboard.show_board
    if state == 'tie'
      puts "It's a Tie!"
    elsif turns == 7 || turns == 8
      puts "Congrats #{state.name}! You won with a perfect game!"
    else
      puts "Congrats #{state.name}! You won!"
    end
  end
end
