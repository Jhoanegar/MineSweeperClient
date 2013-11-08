#Handles the logic 
require_relative './board'
class Agent
  BOARD_STATUS = "BE"
  EMPTY_CELL = "E"
  def initialize(logger)
    @logger = logger
    @board = nil
    @last_message = nil
    @last_play = nil 
    @next_plays = []
  end

  def play(message)
    @last_message = message
    set_attributes
    @logger.debug "Agent: My Board looks like this:\n#{@board.to_s}" 
    if repeat_last_play?
      return make_command
    # elsif @board.cell(@last_play[:x],@last_play[:y]) == EMPTY_CELL
       
    end

    unless @next_plays.empty?
      @logger.debug "Returning next play in queue"
      @last_play = @next_plays.last
      return @next_plays.pop
    end
    random_uncover

    return make_command 
  end

  def random_uncover
    @last_play = Play.new
    @last_play.x = Random.rand(@board.height)
    @last_play.y = Random.rand(@board.width)
    @last_play.command = "UN"
  end

  def repeat_last_play?
    return false if @last_play.nil?
    @logger.debug("Ill test if i need to repeat #{@last_play.inspect}")
    x = @last_play.x
    y = @last_play.y
    cmd = @last_play.command
    @logger.debug("x:#{x} y:#{y} cell:#{@board.cell(x,y)}")
    unless Interpreter.command_matches_state?(cmd,@board.cell(x,y))
      @logger.debug "Repeating command #{@last_play.inspect}"
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
    "(#{@last_play.command} #{@last_play.y} #{@last_play.x})" 
  end

  private 

  def set_board
    if @board.nil?
      @board = Board.new do |board|
      board.cells = @last_message[1][3]
    end
    @logger.debug "Agent: h = #{@board.height}, w = #{@board.width}"
    elsif @last_message[1][4] != nil
      @board.mines = @last_message[1][4]
    end
    @board.cells = @last_message[1][3]
  end

  def last_message=(message)
    @last_message = message
  end

  def width=(w)
    @width = w
  end

  def height=(h)
    @height = h
  end

  def board
    @board
  end
end

