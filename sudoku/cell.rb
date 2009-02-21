module Sudoku
class Cell

    attr_reader :row, :col

    def initialize board, row, col
        @board = board
        @row = row
        @col = col
        @possibles = (1..Board::MAX_VAL).to_a
        @value = nil
    end
    
    def to_s
        "(#{row},#{col})"
    end
    
    def inspect
        "#{to_s}=#{value || '?'}"
    end
    
    def eliminate(value)
        @possibles.delete(value)
    end
    
    def possible?(value)
        @possibles.include?(value)
    end
    
    def possibles=(values)
        @possibles = values
    end

    def possibles
        @possibles
    end
    
    def region
        @region ||= (@row / Board::DIM) * Board::DIM + (@col / Board::DIM)
    end
    
    def value
        @value
    end
    
    def value=(v)
        raise "value was already set once" if @value
        @value = v
        @possibles = []
    end
    
    def solved?
        value != nil
    end
    
    # returns all other cells that are in the same scope as this one
    def related_cells
        return @related_cells if @related_cells
        cells = @board.cells_in_row(row)
        cells += @board.cells_in_col(col)
        cells += @board.cells_in_region(region)
        cells.delete(self)
        @related_cells = cells.uniq
    end
    
    def first_in_row?
        col == 0
    end

    def last_in_row?
        col == Board::MAX_IDX
    end

    def first_in_col?
        row == 0
    end
    
    def last_in_col?
        row == Board::MAX_IDX
    end

    def first_in_region_row?
        col % Board::DIM == 0
    end

    def last_in_region_row?
        col % Board::DIM == Board::DIM - 1
    end

    def first_in_region_col?
        row % Board::DIM == 0
    end

    def last_in_region_col?
        row % Board::DIM == Board::DIM - 1
    end

end
end