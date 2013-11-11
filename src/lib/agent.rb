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
    @possible_flags = []
    @confirmed = nil
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
      when EMPTY_CELL  
        uncover_neighbours
      when NUMERIC_CELL
        @logger.info "Agent: Numeric cell found"
        @possible_flags<<Play.new(@last_play.x,@last_play.y,SET_FLAG_COMMAND) 
      end
      @last_play = nil
    end

    unless @next_plays.empty?
      @logger.info "Returning next play in queue"
      @last_play = @next_plays.last
      return @next_plays.pop.to_command
    end
   
    if can_set_flags? 
      @last_play = @next_plays.last
      return @next_plays.pop.to_command 
    end

    # abort
    
    # if can_do_something_else?
      
    # end
    
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

  def can_do_something_else?
    false
  end

  def can_set_flags?
    return false if @possible_flags.empty?
    ary = []
    @possible_flags.each do |p| 
      covered, uncovered, flagged = analyze_neighbours(p.x,p.y)
      if covered == @board.cell(p.x,p.y).to_i
        flag_neighbours(p.x,p.y)
      elsif flagged == @board.cell(p.x,p.y).to_i
        uncover_neighbours(p.x,p.y)
      else 
        ary << p
      end
    end
    if @possible_flags.size == ary.size
      return false
    else
      @possible_flags = ary
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


  def uncover_neighbours(x=@last_play.x,y=@last_play.y)
    
    @board.each_neighbour(x,y) do |cell,nx,ny|
      p = Play.new(nx,ny,UNCOVER_COMMAND)
      unless @next_plays.include? p or cell != COVERED_CELL
        @next_plays.unshift p
      end 
    end
  end

  def flag_neighbours(x=@last_play.x,y=@last_play.y)
    @board.each_neighbour(x,y) do |cell,nx,ny|
      p = Play.new(nx,ny,SET_FLAG_COMMAND)
      unless @next_plays.include? p or cell != COVERED_CELL
        @next_plays.unshift p
      end 
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
      sleep(70/1000.0)
      return true
    end
    return false
  end

  def set_attributes
    command = @last_message[0]
    case command
    when BOARD_STATUS
      set_board
    when SCORE
      @confirmed = true
    end
  end


  def make_command
    @last_play.to_command
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
  
  attr_accessor :board, :last_message, :last_play, :next_plays, :possible_flags
end
