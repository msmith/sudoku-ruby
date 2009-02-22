require 'sudoku/cell'
require 'erb'

module Sudoku
class Board

    DIM = 3
    DIM2 = DIM*DIM
    MAX_IDX = DIM2-1
    MAX_VAL = DIM2
    
    def initialize(board_string = "")
        @cells = new_cells
        @cells_in_col = []
        @cells_in_region = []
        
        load(board_string)
    end
    
    def [](row, col)
        @cells[row][col]
    end

    def []=(row, col, num)
        cell = self[row,col]
        raise ArgumentError, "[#{row},#{col}]=#{num} is invalid" unless cell.possible?(num)

        cell.related_cells.each { |c| c.eliminate(num) }
        cell.value = num
    end
    
    def cells
        @cells.flatten
    end
    
    def cells_in_row row
        @cells[row]
    end

    def cells_in_col col
        @cells_in_col[col] ||= cells.select { |cell| cell.col == col}
    end

    def cells_in_region region
        @cells_in_region[region] ||= cells.select { |cell| cell.region == region }
    end
    
    def rows
        @rows ||= (0..MAX_IDX).collect { |row| cells_in_row(row) }
    end

    def cols
        @cols ||= (0..MAX_IDX).collect { |col| cells_in_col(col) }
    end

    def regions
        @regions ||= (0..MAX_IDX).collect { |region| cells_in_region(region) }
    end
    
    def scopes
        @scopes ||= rows + cols + regions
    end

    def solved?
        cells.all? { |cell| cell.solved? }
    end
    
    def possibles num
        cells.select { |cell| cell.possible? num }.size
    end

    # human-readable string
    def to_s
        s = ""
        @cells.each do |rows|
            rows.each do |cell|
                s << (cell.value || ".").to_s
                s << " "
                s << " "  if cell.last_in_region_row?
                s << "\n" if cell.last_in_row? && cell.last_in_region_col?
            end
            s << "\n"
        end
        s
    end

    # to sudokusolver.co.uk format
    def to_s2
        s = ""
        cells.each do |cell|
            s << (cell.value || "_").to_s
            s << "+" if cell.last_in_row? and !cell.last_in_col?
        end
        s
    end

    # a single string of 81 numbers, 0 means empty
    def to_s3
        cells.map {|cell| cell.value || "0"}.join
    end

    def to_html
        template_file = File.dirname(__FILE__) + "/board.html.erb"
        template = File.read(template_file)
        ERB.new(template, nil, '>').result(binding)
    end
    
private

    def new_cells
      (0..MAX_IDX).inject([]) { |cells, row| cells << new_empty_row(row) }
    end
    
    def new_empty_row row
      (0..MAX_IDX).map { |col| Cell.new(self, row, col) }
    end

    def load(s)
        s = s.gsub(/\n/,'')
        i = 0
        for row in (0..MAX_IDX) do
            for col in (0..MAX_IDX) do
                next_char = s[i,1]
                num = next_char.to_i
                self[row, col] = num if num > 0
                i += 1
            end
        end
    end
    
end
end