#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "lib")

require "sudoku"

def print_usage
    puts "Usage: #{$0} -f <puzzle_file>"
    puts "       #{$0} -p <puzzle_string>"
    exit 1
end

if __FILE__ == $0

    require 'getoptlong'

    opts = GetoptLong.new(
        ["--puzzle", "-p", GetoptLong::REQUIRED_ARGUMENT ],
        ["--file",   "-f", GetoptLong::REQUIRED_ARGUMENT ],
        ["--turns",  "-t", GetoptLong::REQUIRED_ARGUMENT ],
        ["--html",   "-h", GetoptLong::REQUIRED_ARGUMENT ]
    )

    file_in = nil
    html_out = nil
    puzzle_string = nil
    max_turns = nil
    opts.each do |opt, arg|
        case opt
        when "--file"
            file_in = arg
        when "--html"
            html_out = arg
        when "--puzzle"
            puzzle_string = arg
        when "--turns"
            max_turns = arg.to_i
        end
    end

    print_usage if file_in.nil? and puzzle_string.nil?
    
    if file_in
        puzzle_string = File.read(file_in)
    end

    b = Sudoku::Board.new(puzzle_string)
    puts b

    solver = Sudoku::Solver.new(b)
    solver.solve(max_turns) do |i, cell|
        puts
        puts "#{i}: #{cell} = #{cell.value}"
        puts
        puts b
    end

    if html_out
        html_file = File.new("#{File.dirname(__FILE__)}/#{html_out}", "w")
        html_file.write b.to_html
        puts "Wrote puzzle to #{html_file.path}"
    end

    exit (b.solved?) ? 0 : 1

end
