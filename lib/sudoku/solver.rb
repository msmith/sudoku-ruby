#
# A rule-based solver
#
module Sudoku
class Solver

    def initialize(board)
        @board = board
    end

    # Scan the board for a cell that can be solved
    def scan

        # scan scopes for numbers that appear as a possibility just once
        for num in 1..Board::MAX_VAL
            @board.scopes.each do |scope|
                cells = scope.select { |cell| cell.possible?(num) }
                if cells.size == 1
                    cells.first.possibles = [num]
                end
            end
        end
    
        # scan scopes for pairs or triples
        @board.scopes.each do |scope|
            counts = {} # hash of [array of possible values] => [count]
            scope.each do |cell|
                p = cell.possibles
                next if p.size < 2
                counts[p] ||= 0
                counts[p] += 1
            end
            # only keep [1,2]x2, [4,6,8]x3, [1,2,6,9]x4, etc
            counts = counts.delete_if { |p, count| (p.size != count) }
            sets = counts.keys
        
            # eliminate the numbers if they appear outside the set
            sets.each do |set|
                scope.each do |cell|
                    next if set == cell.possibles
                    cell.possibles -= set
                end
            end
        end
    
        for num in (1..Board::MAX_VAL) do
            # scan rows for number appearing as a possibility in only one region
            @board.rows.each do |row|
                possible_cells = row.select { |cell| cell.possible?(num) }
                next if possible_cells.size < 2
                regions = possible_cells.map { |cell| cell.region }.uniq
                if (regions.size == 1)
                    # remove num from all other cells in the region
                    @board.cells_in_region(regions.first).each do |cell|
                        cell.eliminate(num) unless row.include?(cell)
                    end
                end
            end

            # scan columns for number appearing as a possibility in only one region
            @board.cols.each do |col|
                possible_cells = col.select { |cell| cell.possible?(num) }
                next if possible_cells.size < 2
                regions = possible_cells.map { |cell| cell.region }.uniq
                if (regions.size == 1)
                    # remove num from all other cells in the region
                    @board.cells_in_region(regions.first).each do |cell|
                        cell.eliminate(num) unless col.include?(cell)
                    end
                end
            end
        end

        # solve cells which have only one remaining possibility
        @board.cells.each do |cell|
            if cell.possibles.size == 1
                @board[cell.row,cell.col] = cell.possibles.first
                return cell
            end
        end

        # stuck!
        return nil
    end

    # Solves the board
    def solve(max_rounds = nil)
        round = 0
        while cell = scan do
            break if max_rounds && round >= max_rounds
            round = round + 1
            yield(round, cell) if block_given?
        end
    end

end
end
