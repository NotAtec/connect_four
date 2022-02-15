# frozen_string_literal: true

require_relative '../lib/connect_four'

describe Game do
  describe '.create_player' do
    subject(:empty_game) { described_class }

    context 'when input is as required' do
      before do
        allow(empty_game).to receive(:token_check).and_return('Y')
        allow(empty_game).to receive(:puts)
        allow(empty_game).to receive(:gets).and_return('name', 'Y')
      end

      it 'returns a player object' do
        object = empty_game.create_player
        expect(object).to be_a(Player)
      end

      it 'contains the right details in the new obj' do
        object = empty_game.create_player
        name = object.instance_variable_get(:@name)
        token = object.instance_variable_get(:@token)
        expect(name).to eq('name')
        expect(token).to eq('Y')
      end
    end

    context 'when input is correct 2nd try' do
      before do
        allow(empty_game).to receive(:token_check).and_return(nil, 'Y')
        allow(empty_game).to receive(:puts)
        allow(empty_game).to receive(:gets).and_return('name', 'ab', 'Y')
      end

      it 'creates player with correct info' do 
        object = empty_game.create_player
        name = object.instance_variable_get(:@name)
        token = object.instance_variable_get(:@token)
        expect(name).to eq('name')
        expect(token).to eq('Y')
      end
    end
  end

  describe '.token_check' do
    subject(:game_input) { described_class }

    context 'when valid input is given' do
      it 'returns the input' do
        input = 'A'
        result = game_input.token_check(input)
        expect(result).to eq('A')
      end
    end

    context 'when valid, but non-capitalized input is given' do
      it 'capitalizes the input' do
        input = 'a'
        result = game_input.token_check(input)
        expect(result).to eq('A')
      end
    end

    context 'when invalid input is given' do
      before do
        allow(game_input).to receive(:puts)
      end

      it 'returns nil' do
        input = 'abx0'
        result = game_input.token_check(input)
        expect(result).to be_nil
      end

      it 'gives appropriate error (length)' do
        error = "Please input only 1 character"
        input = 'abx0'
        expect(game_input).to receive(:puts).with(error)
        game_input.token_check(input)
      end

      it 'gives appropriate error (letters only)' do
        error = "Please input a letter (A-Z)"
        input = '0'
        expect(game_input).to receive(:puts).with(error)
        game_input.token_check(input)
      end
    end
  end

  describe '#play_game' do
    let(:player_one) { instance_double(Player, name: 'one', token: 'x') }
    let(:player_two) { instance_double(Player, name: 'two', token: 'y') }
    subject(:game_played) { described_class.new(player_one, player_two, board) }
    let(:board) { instance_double(Board) }

    context 'when win check returns true' do
      before do
        allow(board).to receive(:game_end?).and_return(true)
        game_played.instance_variable_set(:@turn, 3)
        allow(game_played).to receive(:win_message)
      end

      it 'breaks the loop' do
        expect(board).to receive(:game_end?).once
        game_played.play_game
      end

      it 'triggers #win_message' do
        expect(game_played).to receive(:win_message).once
        game_played.play_game
      end

      it 'gives #win_message the correct details' do
        expect(game_played).to receive(:win_message).with("not_started", 3)
        game_played.play_game
      end
    end

    context 'when win check returns false then true' do
      before do
        allow(board).to receive(:game_end?).and_return(false, true)
        allow(board).to receive(:place_token)
        allow(game_played).to receive(:col_input)
        allow(game_played).to receive(:win_message)
        allow(board).to receive(:show_board)
      end

      it 'triggers player input' do
        expect(game_played).to receive(:col_input).once
        game_played.play_game
      end

      it 'gives player input correct details' do
        expect(game_played).to receive(:col_input).with('one').once
        game_played.play_game
      end

      it 'gives player input correct details (p2)' do
        game_played.instance_variable_set(:@turn, 1)
        expect(game_played).to receive(:col_input).with('two').once
        game_played.play_game
      end

      it 'breaks the loop after' do
        expect(board).to receive(:game_end?).twice
        game_played.play_game
      end

      it 'gives #win_message the correct details' do
        expect(game_played).to receive(:win_message).with('not_started', 1)
        game_played.play_game
      end
    end
  end

  describe '#col_check' do
    let(:player_one) { instance_double(Player, name: 'one', token: 'x') }
    let(:player_two) { instance_double(Player, name: 'two', token: 'y') }
    subject(:game_col_input) { described_class.new(player_one, player_two) }

    context 'when valid input is given' do
      it 'returns the input' do
        input = '4'
        result = game_col_input.col_check(input)
        expect(result).to eq('4')
      end
    end

    context 'when invalid input is given' do
      before do
        allow(game_col_input).to receive(:puts)
      end

      it 'returns nil' do
        input = 'a'
        result = game_col_input.col_check(input)
        expect(result).to be_nil
      end

      it 'outputs correct error (length)' do
        error = "Please input only 1 character"
        input = '00'
        expect(game_col_input).to receive(:puts).with(error)
        game_col_input.col_check(input)
      end

      it 'outputs correct error (NAN / outside range)' do
        error = "Please input a number between 0 - 6"
        input = '7'
        expect(game_col_input).to receive(:puts).with(error)
        game_col_input.col_check(input)
      end
    end
  end
  describe '#win_message' do
    let(:player_one) { instance_double(Player, name: 'one', token: 'x') }
    let(:player_two) { instance_double(Player, name: 'two', token: 'y') }
    subject(:game_played) { described_class.new(player_one, player_two, board) }
    let(:board) { instance_double(Board) }

    context 'when message is triggered with perfect play' do
      it 'shows correct message' do
        message = "Congrats one! You won with a perfect game!\n"
        expect { game_played.win_message(player_one.name, 7) }.to output(message).to_stdout
      end

      it 'shows correct message' do
        message = "Congrats two! You won with a perfect game!\n"
        expect { game_played.win_message(player_two.name, 8) }.to output(message).to_stdout
      end
    end

    context 'when message is triggered with win' do
      it 'shows correct message' do
        message = "Congrats one! You won!\n"
        expect { game_played.win_message(player_one.name, 10) }.to output(message).to_stdout
      end
    end

    context 'when message is triggered without win' do
      it 'shows correct message' do
        message = "It's a Tie!\n"
        expect { game_played.win_message('tie', 7) }.to output(message).to_stdout
      end
    end
  end
end

describe Board do
  describe '#place_token' do
    subject(:board) { described_class.new }
    context 'column is empty' do
      before do
        board.instance_variable_set(:@board, Array.new(7) { Array.new(6) })
      end

      it 'places token on bottom row' do
        board.place_token('x', 0)
        cell = board.instance_variable_get(:@board)[0][0]
        expect(cell).to eq('x')
      end
    end

    context 'when other column is not empty, but required one is' do
      before do
        not_empty = Array.new(7) { Array.new(6) }
        not_empty[0][0] = 'y'
        board.instance_variable_set(:@board, not_empty)
      end

      it 'places token in correct column' do
        board.place_token('x', 1)
        cell = board.instance_variable_get(:@board)[1][0]
        expect(cell).to eq('x')
      end
    end

    context 'when column is not empty' do
      before do
        not_empty = Array.new(7) { Array.new(6) }
        not_empty[0][0] = 'y'
        board.instance_variable_set(:@board, not_empty)
      end

      it 'places token in correct column, on correct row' do
        board.place_token('x', 0)
        cell = board.instance_variable_get(:@board)[0][1]
        expect(cell).to eq('x')
      end
    end

    context 'when column is full' do
      before do
        not_empty = Array.new(6) { Array.new(6) }
        not_empty.unshift(Array.new(6, 'y'))
        board.instance_variable_set(:@board, not_empty)
      end

      it 'returns an error' do
        expect(board.place_token('x', 0)).to eq('col_full')
      end
    end
  end

  describe '#game_end?' do
    subject(:board) { described_class.new }

    context 'win in column at 0' do
      before do
        b = board.instance_variable_get(:@board)
        4.times do |i|
          b[0][i] = 'x'
        end
        board.instance_variable_set(:@board, b)
      end

      it 'returns true' do
        result = board.game_end?('x', 'y')
        expect(result).to eq('one')
      end
    end

    context 'win in column, non 0' do
      before do
        b = board.instance_variable_get(:@board)
        4.times do |i|
          b[0][i + 1] = 'y'
        end
        board.instance_variable_set(:@board, b)
      end

      it 'returns true' do
        result = board.game_end?('x', 'y')
        expect(result).to eq('two')
      end
    end
    
    context 'win in row at 0' do
      before do
        b = board.instance_variable_get(:@board)
        4.times do |i|
          b[i][0] = 'x'
        end
        board.instance_variable_set(:@board, b)
      end

      it 'returns true' do
        result = board.game_end?('x', 'y')
        expect(result).to eq('one')
      end
    end

    context 'win in row, non 0' do
      before do
        b = board.instance_variable_get(:@board)
        4.times do |i|
          b[i + 1][0] = 'x'
        end
        board.instance_variable_set(:@board, b)
      end

      it 'returns true' do
        result = board.game_end?('x', 'y')
        expect(result).to eq('one')
      end
    end

    context 'win in cross, top = left' do
      before do
        b = board.instance_variable_get(:@board)
        4.times do |i|
          b[5 - i][5 - i] = 'x'
        end
      end

      it 'returns true' do
        result = board.game_end?('x', 'y')
        expect(result).to eq('one')
      end
    end

    context 'win in cross, top = right' do
      before do
        b = board.instance_variable_get(:@board)
        4.times do |i|
          b[i][i] = 'y'
        end
        board.instance_variable_set(:@board, b)
      end

      it 'returns true' do
        result = board.game_end?('x', 'y')
        expect(result).to eq('two')
      end
    end

    context 'no win' do
      it 'returns false' do
        result = board.game_end?('x', 'y')
        expect(result).to be false
      end
    end
  end
end
