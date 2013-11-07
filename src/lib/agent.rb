#Handles the logic 
require_relative './board'
class Agent
  BOARD_STATUS = "BE"

  def initialize(logger)
    @logger = logger
    @board = nil
    @last_message = nil
    @last_play = nil 
    @next_plays = []
  end

  def play(message)
    self.last_message = message
    set_attributes
    
    if repeat_last_play?
      return make_command
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
    @last_play = {}
    @last_play[:x] = Random.rand(0..@board.width)
    @last_play[:y] = Random.rand(0..@board.height)
    @last_play[:command] = "UN"
  end

  def repeat_last_play?
    return false if @last_play.nil?
    @logger.debug "Ill test if i need to repeat #{@last_play.inspect}"
    x = @last_play[:x]
    y = @last_play[:y]
    cmd = @last_play[:command]
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
  end

  def make_command
    "(#{@last_play[:command]} #{@last_play[:x]} #{@last_play[:y]})" 
  end
  private #for testing purposes 


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

