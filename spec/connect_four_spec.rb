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
      it 'returns nil' do
        input = 'abx0'
        result = game_input.token_check(input)
        expect(result).to be_nil
      end

      it 'gives appropriate error (length)' do
        error = "Please input only 1 character\n"
        input = 'abx0'
        expect { game_input.token_check(input) }.to output(error).to_stdout
      end

      it 'gives appropriate error (letters only)' do
        error = "Please input a letter (A-Z)\n"
        input = '0'
        expect { game_input.token_check(input) }.to output(error).to_stdout
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
  end

  describe '#win_message' do
    let(:player_one) { instance_double(Player, name: 'one', token: 'x') }
    let(:player_two) { instance_double(Player, name: 'two', token: 'y') }
    subject(:game_played) { described_class.new(player_one, player_two, board) }
    let(:board) { instance_double(Board) }

    context 'when message is triggered with perfect play' do
      it 'shows correct message' do
        message = "Congrats one! You won with a perfect game!\n"
        expect { game_played.win_message(player_one.name, 6) }.to output(message).to_stdout
      end

      it 'shows correct message' do
        message = "Congrats two! You won with a perfect game!\n"
        expect { game_played.win_message(player_two.name, 7) }.to output(message).to_stdout
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
end
