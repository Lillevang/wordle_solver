require "./word_list"
require "colorize"

class WordlSolver

  @eliminated = Set(Char).new
  @word_includes = Set(Char).new
  @guess = Hash(Int32, Char).new
  @eliminated_at = Hash(Int32, Char).new

  def initialize
    @filtered_wordlist = WordleSolverUtil.get_wordlist
  end

  def process_word(word : String)
    word.split(" ").each_with_index do |c, i|
      if c.includes?('?')
        @word_includes << c.chars[0]
        @eliminated_at[i] = c.chars[0]
      elsif c.includes?('!')
        @word_includes << c.chars[0]
        @guess[i] = c.chars[0]
      else
        @eliminated << c.chars[0]
      end
    end
    p "Word includes following letters: #{@word_includes}"
    filter_wordlist
    unless @filtered_wordlist.size <= 20
      p "Many words still in wordlist. Try some of the following chars:"
      suggest_chars
    end
    suggest_word
  end

  def filter_wordlist
    unless @word_includes.empty?
      new_filter = @filtered_wordlist.select { |word|
      @word_includes.all? { |c| word.chars.includes?(c) } &&
      !@eliminated.any? { |c| word.chars.includes?(c) }}
      filter_using_location_in_word(new_filter)
      filter_using_eliminated_location_in_word(new_filter)
    end
    @filtered_wordlist = new_filter.not_nil!
    print_status
  end

  def filter_using_location_in_word(new_filter : Array(String))
    tmp_wl = new_filter.clone
    unless @guess.keys.empty?
      tmp_wl.each do |w|
        @guess.keys.each do |i|
          if w[i] != @guess[i]
            new_filter.delete(w)
            #TODO: continue - no reason to check more
          end
        end
      end
    end
  end

  def filter_using_eliminated_location_in_word(new_filter : Array(String))
    tmp_wl = new_filter.clone
    unless @eliminated_at.keys.empty?
      tmp_wl.each do |w|
        @eliminated_at.keys.each do |i|
          if w[i] == @eliminated_at[i]
            new_filter.delete(w)
            #TODO: continue - no reason to check more
          end
        end
      end
    end
  end

  def suggest_chars
    chars = @filtered_wordlist.map(&.chars)
    chars.transpose.each_with_index do |x, i|
      p "#{i}: #{x.max_by{|c| x.count(c)}}"
    end
  end

  def suggest_word
    if @filtered_wordlist.size == 1
      p "Word is: #{@filtered_wordlist[0]}".colorize.green.underline
      exit
    elsif @filtered_wordlist.size < 10
      p @filtered_wordlist
    else
      p "Random word remaining in wordlist is:"
      p @filtered_wordlist[Random.rand(@filtered_wordlist.size)]
    end
  end

  def add_invalid_chars(s : String)
    cnt = 0
    s.split(" ").each do |c|
      if !@eliminated.includes?(c.chars[0])
        @eliminated << c.chars[0]
        cnt += 1
      else
        p "#{c.chars[0]} already eliminated."
      end
    end
    p "Eliminated #{cnt} chars. Filtering wordlist started."
    new_list = @filtered_wordlist.clone
    #TODO: refactor using any/all instead of the loop
    new_list.each do |w|
      @eliminated.each do |c|
        if w.includes?(c)
          @filtered_wordlist.delete(w)
          #TODO: continue.
        end
      end
    end
  end

  def add_valid_chars(s : String)
    #TODO: Could be useful!
  end

  def print_status
    p "The wordlist is filtered down to: #{@filtered_wordlist.size} words".colorize.yellow
  end
end

class Cli

  @welcome = true
  @solver = WordlSolver.new

  def initialize
    p "Solver instantiated. Last recorded word was: #{last_word_recorded}"
    @solver.print_status
    start_interaction
  end

  def start_interaction
    # TODO: Add -a which will append and save the solution to the previous_words file.
    # TODO: Handle words with letters in multiple places like: cered <- In that case e is correct in two positions which the program currently doesn't support.
    while true
      print_welcome if @welcome
      user_input = gets
      cmd = user_input.not_nil!.split(" ")[0]
      exit if user_input == "exit" || user_input == "quit"
      if user_input == "-x" || user_input == "hack" || user_input == "x"
        p hack.colorize.green
        exit
      elsif cmd == "-e" || cmd == "e" || cmd == "eliminate"
        @solver.add_invalid_chars(user_input.not_nil!.split(" '")[1])
        @solver.print_status
      elsif cmd == "-w" || cmd == "w" || cmd == "word"
        @solver.process_word(user_input.not_nil!.split(" '")[1])
      elsif cmd == "-h" || cmd == "--help" || cmd == "h"
        print_help
      else
        p "Invalid command".colorize.red.underline
      end
    end
  end

  def print_welcome
    p "Welcome to the wordle solver. To add data use one of the following commands:"
    print_help
    @welcome = false
  end

  def print_help
    p "-h || --help    - prints this help message".colorize.blue
    p "-e 'c h a r s'  - a whitespace separated list of chars to eliminate.".colorize.yellow
    p "-w 's u g a? r' - a whitespace separated list of chars to process. A char followed by '?' is included in the word at another position. A char followed by '!' is in the correct position.".colorize.yellow
    p "-x || x || hack - runs the hack on the wordlist and prints todays solution.".colorize.red.bold
  end

  def hack
    line = File.read("./previous_words.txt").split("\n")[-1].split(": ")
    date_of_solve = Time.parse(line[0], "%d/%m/%Y", Time::Location::UTC)
    last_solution = line[1]
    days_since_solve = (Time.local - date_of_solve).days
    wl = WordleSolverUtil.get_wordlist
    wl[(wl.index(last_solution).not_nil! + days_since_solve + 1)]
  end

  def last_word_recorded
    File.read("./previous_words.txt").split("\n")[-1].split(": ")[1]
  end
end

c = Cli.new
