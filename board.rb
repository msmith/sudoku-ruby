require 'cell'

class Board

    DIM = 3
    DIM2 = DIM*DIM
    MAX_IDX = DIM2-1
    MAX_VAL = DIM2
    
    def initialize
        reset
        @cells_in_col = []
        @cells_in_region = []
    end
    
    def reset
        @cells = []
        for row in (0..MAX_IDX) do
            @cells[row] = []
            for col in (0..MAX_IDX) do
                @cells[row] << Cell.new(self, row, col)
            end
        end
    end
    
    def load(s)
        s = s.gsub(/\n/,'')
        i = 0
        for row in (0..MAX_IDX) do
            for col in (0..MAX_IDX) do
                num = s[i,1].to_i
                i += 1
                self[row, col] = num if num > 0
            end
        end
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

    def to_html highlight=nil
        s = "<html>"
        s << "<head><style>"
        s << "
        table { border-collapse: collapse }
        span.e { visibility: hidden }
        span.p { color: #CCC }
        td { letter-spacing: 2px; text-align: center; vertical-align: middle }
        td { width: 2.2em; height: 2.2em; border: 1px solid gray; padding: 5px }
        td.t { border-top: 2px solid }
        td.l { border-left: 2px solid }
        td.b { border-bottom: 2px solid }
        td.r { border-right: 2px solid }
        td.s { font-size: 130%; font-weight: bold }"
        s << "</style></head>\n"
        s << "<body><table  style='float:left' border='0' cellspacing='0'>\n"
        cells.each do |cell|
            s << "<tr>" if (cell.first_in_row?)
            cssclass = ""
            cssclass << " t" if (cell.first_in_region_col?)
            cssclass << " l" if (cell.first_in_region_row?)
            cssclass << " b" if (cell.last_in_region_col?)
            cssclass << " r" if (cell.last_in_region_row?)
            cssclass << " s" if (cell.solved?)
            s << "<td class='#{cssclass.strip}'>"
            if (cell.solved?)
                s << (cell.value || ".").to_s
            else
                (1..MAX_VAL).each do |v|
                    if cell.possible?(v)
                        s << "<span class='p'>#{v}</span>"
                    else
                        s << "<span class='e'>#{v}</span>"
                    end
                    s << "<br/>" if (v % DIM == 0)
                end
            end
            s << "</td>\n"
            s << "</tr>\n" if (cell.last_in_row?)
        end
        s << "</table><table style='float:right'><tr><td>num</td><td>possibles</td></tr>"
        (1..MAX_VAL).each do |num|
            s << "<tr><td>#{num}</td><td>#{possibles(num)}</td></tr>"
        end
        s << "</table></body></html>"
    end
    
    # scans the board for a cell that can be solved
    def scan

        # scan scopes for numbers that appear as a possibility just once
        for num in 1..MAX_VAL
            scopes.each do |scope|
                cells = scope.select { |cell| cell.possible?(num) }
                if cells.size == 1
                    cells.first.possibles = [num]
                end
            end
        end
        
        # scan scopes for pairs or triples
        scopes.each do |scope|
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
                    cell.possibles.delete_if { |num| set.include?(num) }
                end
            end
        end
        
        for num in (1..MAX_VAL) do
            # scan rows for number appearing as a possibilities in only one region
            rows.each do |row|
                possible_cells = row.select { |cell| cell.possible?(num) }
                next if possible_cells.size < 2
                regions = possible_cells.map { |cell| cell.region }.uniq
                if (regions.size == 1)
                    # remove num from all other cells in the region
                    cells_in_region(regions.first).each do |cell|
                        cell.eliminate(num) unless row.include?(cell)
                    end
                end
            end

            # scan columns for number appearing as a possibilities in only one region
            cols.each do |col|
                possible_cells = col.select { |cell| cell.possible?(num) }
                next if possible_cells.size < 2
                regions = possible_cells.map { |cell| cell.region }.uniq
                if (regions.size == 1)
                    # remove num from all other cells in the region
                    cells_in_region(regions.first).each do |cell|
                        cell.eliminate(num) unless col.include?(cell)
                    end
                end
            end
        end
   
        # solve cells which have only one remaining possibility
        cells.each do |cell|
            if cell.possibles.size == 1
                self[cell.row,cell.col] = cell.possibles.first
                return cell
            end
        end

        # stuck!
        return nil
    end
    
    # Solves the board.
    def solve(max_turns = nil)
        turn = 0
        while cell = scan do
            break if max_turns && turn >= max_turns
            turn = turn + 1
            yield(turn, cell) if block_given?
        end
    end

end