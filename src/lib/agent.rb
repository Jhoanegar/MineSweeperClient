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
  REMOVE_FLAG_COMMAND = "RF"
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
    elsif undo_last_play?
      return @last_play.to_command
    elsif @last_play
      @logger.info "I didn't have to repeat the play."
      case @board.cell(@last_play.coords)
      when EMPTY_CELL #comment if server is updated
        modify_neighbours UNCOVER_COMMAND
      when NUMERIC_CELL
        @logger.info "Agent: Numeric cell found"
      end
    end

    # if commented, the performance may be improved buy it
    # may repeat the enemy moves
    clean_next_plays!

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

  def undo_last_play?
    return false if @last_play.nil?
    if @last_play.command == SET_FLAG_COMMAND
      @logger.info "I'll test if I need to undo  #{@last_play.to_command}"
      unless @set_flag_confirmed
        @last_play.command = REMOVE_FLAG_COMMAND
        @logger.info "I'll undo the last play with #{@last_play.to_command}"
        return true
      else
        @logger.info "I won't undo the last play"

        return false
      end
    end
  end

  def clean_next_plays!
    @next_plays.select! do |p|
      if p.command == UNCOVER_COMMAND
        @board.cell(p.coords) == COVERED_CELL
      elsif p.command == SET_FLAG_COMMAND
        @board.cell(p.coords) == FLAGGED_CELL
      else
        false
      end
    end
  end

  def random_uncover
    x = 0
    y = 0
    loop do
      x = Random.rand(@board.width)
      y = Random.rand(@board.height)
      break if @board.cell(x,y) == COVERED_CELL or @last_play.nil?
    end 
    @last_play = Play.new
    @last_play.x = x 
    @last_play.y = y
    unless @set_flag_confirmed.nil?
      @last_play.command = SET_FLAG_COMMAND
    else
      @last_play.command = UNCOVER_COMMAND
    end
    @last_play.to_command
  end

  def can_set_flags?
    set_numeric_cells
    return false if @numeric_cells.empty?
    rejected = 0
    @numeric_cells.each do |p| 
      cell = @board.cell(p.coords).to_i
      covered, uncovered, flagged = analyze_neighbours(p.x,p.y)
      if cell - flagged >= covered 
        modify_neighbours(SET_FLAG_COMMAND,p.x,p.y,)
        @set_flag_confirmed = false
      elsif flagged == cell and uncovered > 0
        modify_neighbours(UNCOVER_COMMAND,p.x,p.y,)
      else 
        rejected += 1
      end
    end
    if rejected == @numeric_cells.size 
      return false
    else
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
    @logger.info("Ill test if i need to repeat #{@last_play.to_command}")
    x = @last_play.x
    y = @last_play.y
    cmd = @last_play.command
    @logger.info("x:#{x} y:#{y} cell:#{@board.cell(x,y)}")
    unless command_matches_state?(cmd,@board.cell(x,y))
      @logger.info "Repeating command #{@last_play.inspect}"
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
    @logger.info "Score updated, Mines left: #{score[1]}"
    @score = score[1]
    if @last_play 
      if @last_play.command == SET_FLAG_COMMAND
        @set_flag_confirmed = true
      end
    end
  end

  def print_play(arr)
    ret = "\n"
    arr.each { |p| ret << p.to_command }
    ret
  end

  def set_board
    if @board.nil?
      @board = Board.new { |board| board.cells = @last_message[1][3]}
      @logger.info "Agent: h = #{@board.height}, w = #{@board.width}"
    elsif @last_message[1][4] != nil
      @board.mines = @last_message[1][4]
    end
    
    @board.cells = @last_message[1][3]
  end

  def command_matches_state?(command,cell)
    cell_state = cell.chars.last
    case command 
    when UNCOVER_COMMAND
      return true if cell_state != "C" 
    when SET_FLAG_COMMAND
      return true if cell_state != "C" 
    when REMOVE_FLAG_COMMAND
      return true if cell_state == "C" 
    end
    false 
  end

  attr_accessor :board, :last_message, :last_play, :next_plays, :numeric_cells
end
