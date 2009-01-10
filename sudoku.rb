#!/usr/bin/env ruby

require 'board'

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
    puzzle = nil
    max_turns = nil
    opts.each do |opt, arg|
        case opt
        when "--file"
            file_in = arg
        when "--html"
            html_out = arg
        when "--puzzle"
            puzzle = arg
        when "--turns"
            max_turns = arg.to_i
        end
    end

    unless file_in or puzzle
        puts "You must provide a puzzle (-p) or puzzle file (-f)"
        exit 1
    end

    b = Board.new
    if (file_in)
        b.load(File.read(file_in))
    elsif (puzzle)
        b.load(puzzle)
    end

    puts b
    b.solve(max_turns) do |i, cell|
        puts
        puts "#{i}: #{cell} = #{cell.value}"
        puts
        puts b
    end

    puts b.to_s3 unless b.solved?

    if html_out
        html_file = File.new("#{File.dirname(__FILE__)}/#{html_out}", "w")
        html_file.write b.to_html
        puts "Wrote puzzle to #{html_file.path}"
    end

end