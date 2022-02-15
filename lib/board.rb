# Contains info for the playable board and methods regarding it
class Board
  def initialize
    @board = Array.new(7) { Array.new(6) }
  end

  def game_end(token_one, token_two)
    state = four_in_row(token_one, token_two, @board) ||
             four_in_row(token_one, token_two, @board.transpose)  ||
             four_in_row(token_one, token_two, diagonals(@board)) ||
             four_in_row(token_one, token_two, antediagonals(@board)) ||
             game_tied(@board)

    case state
    when token_one
      'one'
    when token_two
      'two'
    when 'tie'
      'tie'
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
    strings = setup_strings(@board.transpose)
    strings.reverse_each { |s| puts s }
    puts '----------------------------'
  end

  private

  def game_tied(board)
    tied = 'tie'
    board.each do |row|
      tied = false unless row.all? { |x| !x.nil? }
    end
    tied
  end

  def four_in_row(one, two, rows)
    rows.each do |row|
      row.each_cons(4) do |set|
        return set[0] if set.all? { |x| x == one } && !set[0].nil?
        return set[0] if set.all? { |x| x == two } && !set[0].nil?
      end
    end
    false
  end

  def diagonals(board)
    (0..board.size - 4).map do |i|
      (0..board.size - 1 - i).map { |j| board[i + j][j] }
    end.concat((1..board.first.size - 4).map do |j|
      (0..board.size - j - 1).map { |i| board[i][j + i] }
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
          string <<  " #{cell} "
        end

        string << '|'
      end
      strings << string
    end
    strings
  end
end
