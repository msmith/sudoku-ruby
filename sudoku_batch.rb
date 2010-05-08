#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "lib")

require "sudoku"

def print_usage
    puts "Usage: #{$0} <puzzleset_filename>"
    exit 1
end

if __FILE__ == $0

    puzzle_set = ARGV[0]

    print_usage if puzzle_set.nil?

    solved = 0
    total = 0

    start = Time.now

    out = ""

    puts "Solving boards from #{puzzle_set}"
    puts

    File.open(puzzle_set) do |f|
        f.each_line do |line|
            b = Sudoku::Board.new(line)
            Sudoku::HeuristicSolver.new(b).solve
            solved += 1 if b.solved?
            total += 1
            secs = (Time.now - start)
            printf "%s %d/%d (%d%%) %2.2f per second\n", b.solved? ? "solved" : "stuck ", solved, total, solved*100/total, total/secs
            # puts line unless b.solved?
        end
    end

end
