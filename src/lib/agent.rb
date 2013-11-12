#Handles the logic 
require_relative './board'
class Agent
  BOARD_STATUS = "BE"
  SCORE = "SCORE"
  EMPTY_CELL = "E"
  COVERED_CELL = "C"
  FLAGGED_CELL = "F"
  NUMERIC_CELL = /\d/
  UNCOVERED_CELL = /\d|E/
  
  UNCOVER_COMMAND = "UN"
  SET_FLAG_COMMAND = "SF" 
  def initialize(logger)
    @logger = logger
    @board = nil
    @last_message = nil
    @last_play = nil 
    @next_plays = []
    @numeric_cells = []
    @confirmed = nil
    @score = 0
  end

  def play(message)
    @last_message = message
    set_attributes
    @logger.info "Agent: My Board looks like this:\n#{@board.to_s}" 
    if repeat_last_play?
      return @last_play.to_command
    elsif @last_play
      @logger.info "I didn't have to repeat the play."
      case @board.cell(@last_play.x,@last_play.y)
      when EMPTY_CELL #comment if server is updated
        modify_neighbours UNCOVER_COMMAND
      when NUMERIC_CELL
        @logger.info "Agent: Numeric cell found"
      end
    end

    unless @next_plays.empty?
      @logger.info "Returning next play in queue"
      @last_play = @next_plays.last
      return @next_plays.pop.to_command
    end

    if @last_play 
      if can_set_flags? and @next_plays.size > 0 
          @last_play = @next_plays.last
          return @next_plays.pop.to_command
      else
        @logger.info "There is no rational thing to do"
      end
    end

    @logger.info "Sending random play"
    return random_uncover
  end

  def random_uncover
    @last_play = Play.new
    @last_play.x = Random.rand(@board.width)
    @last_play.y = Random.rand(@board.height)
    @last_play.command = UNCOVER_COMMAND
    @last_play.to_command
  end

  def neighbours_are_in_straight_line?(x,y)
    return false unless size_of_covered_neighbours(x,y) == 3
    each_covered_neighbour(x,y) do |cell, nx, ny|
      next unless cell == COVERED_CELL
      row ||= ny
      col ||= nx
      next if row == ny and col == nx
      puts "col:#{col} == x:#{x} ; row:#{row} == y:#{y}"
      return false unless (col == x) ^ (row == y)
    end
    return true
  end

  def can_set_flags?
    set_numeric_cells
    return false if @numeric_cells.empty?
    ary = []
    @numeric_cells.each do |p| 
      cell = @board.cell(p.x,p.y).to_i
      covered, uncovered, flagged = analyze_neighbours(p.x,p.y)
      if cell - flagged >= covered and flagged != cell
        modify_neighbours(SET_FLAG_COMMAND,p.x,p.y,)
      elsif flagged == cell and uncovered > 0
        modify_neighbours(UNCOVER_COMMAND,p.x,p.y,)
      else 
        ary << p
      end
    end
    if @numeric_cells.size == ary.size or ary.size == 0
      return false
    else
      @numeric_cells = ary
      return true
    end
  end

  def analyze_neighbours(x,y)
    covered = uncovered = flagged = 0
    @board.each_neighbour(x,y) do |cell,nx,ny|
      case cell.to_s
      when COVERED_CELL
        covered += 1
      when UNCOVERED_CELL
        uncovered += 1
      when FLAGGED_CELL
        flagged += 1
      end
    end
    [covered, uncovered, flagged] 
  end


  def modify_neighbours(command = nil,x = @last_play.x, y = @last_play.y)
    @board.each_neighbour(x,y) do |cell,nx,ny|
      p = Play.new(nx,ny,command)
      unless @next_plays.include? p or cell != COVERED_CELL
        # @logger.info %{I will send #{command} to all the neighbours of
        # #{x},#{y} because covered, uncovered, flagged:
        #{analyze_neighbours(x,y)}}
        @next_plays.unshift p if p.command == UNCOVER_COMMAND
        @next_plays.push p if p.command == SET_FLAG_COMMAND
      end 
    end
  end


  def set_numeric_cells
    @numeric_cells = []
    @board.each do |cell,x,y|
      @numeric_cells << Play.new(x,y,nil) if cell =~ /\d/
    end
  end

  def repeat_last_play?
    return false if @last_play.nil?
    @logger.info("Ill test if i need to repeat #{@last_play.inspect}")
    x = @last_play.x
    y = @last_play.y
    cmd = @last_play.command
    @logger.info("x:#{x} y:#{y} cell:#{@board.cell(x,y)}")
    unless Interpreter.command_matches_state?(cmd,@board.cell(x,y))
      @logger.info "Repeating command #{@last_play.inspect}"
      # sleep(70/1000.0)
      return true
    end
    return false
  end

  def set_attributes
    command = @last_message[0]
    case command
    when BOARD_STATUS
      set_board
    end
  end


  def make_command
    @last_play.to_command
  end

  def score=(score)
    @logger.info "Score updated, Mines left: #{score}"
    @score = score
  end

  def print_play(arr)
    ret = "\n"
    arr.each { |p| ret << p.to_command }
    ret
  end

  def count_neighbours(x,y,status)
    count = 0
    @board.each_neighbour(x,y) do |cell|
      case cell
      when status
        count += 1
      end
    end
    return count
  end

  def each_special_neighbour(x,y,type)
    @board.each_neighbour(x,y) do |cell, nx, ny|
      case cell
      when type
        yield cell, nx, ny
      end
    end
  end

  def method_missing(method_name, *args, &block)
    if method_name =~ /(size|number)_of_(.*)_neighbours/ and args.size == 2
      case $2
      when "covered"
        count_neighbours(args[0],args[1],COVERED_CELL, &block)
      else
        super method_name, *args, &block
      end
    elsif method_name =~ /each_(.*)_neighbour/ and args.size == 2
      case $2
      when "covered"
        each_special_neighbour(args[0],args[1],COVERED_CELL,&block)
      end
    else
      super method_name, *args
    end
  end
  private 

  def set_board
    if @board.nil?
      @board = Board.new { |board| board.cells = @last_message[1][3]}
      @logger.info "Agent: h = #{@board.height}, w = #{@board.width}"
    elsif @last_message[1][4] != nil
      @board.mines = @last_message[1][4]
    end
    
    @board.cells = @last_message[1][3]
  end
  attr_accessor :board, :last_message, :last_play, :next_plays, :numeric_cells
end
