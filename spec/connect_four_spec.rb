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
end
