#!/usr/bin/env ruby

require 'sudoku/board'

if __FILE__ == $0

    FILE = ARGV[0] || "sets/sudoku17"

    solved = 0
    total = 0

    start = Time.now

    out = ""

    puts "Solving boards from #{FILE}"
    puts

    File.open(FILE) do |f|
        f.each_line do |line|
            b = Sudoku::Board.new(line)
            b.solve
            solved += 1 if b.solved?
            total += 1
            secs = (Time.now - start)
            printf "%s %d/%d (%d%%) %2.2f per second\n", b.solved? ? "solved" : "stuck ", solved, total, solved*100/total, total/secs
            # puts line unless b.solved?
        end
    end

end