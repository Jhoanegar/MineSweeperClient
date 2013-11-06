#Handles the logic 
require_relative './board'
class Agent
  BOARD_STATUS = "BE"
  def initialize(logger)
    @logger = logger
    @board = nil
    @last_message = nil
    @last_play = {} 
    @next_plays = []
  end

  def play(message)
    @last_message = message
    set_attributes
    
    if repeat_last_play?
      return @last_play
    end

    unless @next_plays.empty?
      @last_play = @next_plays.last
      return @next_plays.pop
    end
    puts "Gets to last Play" 
    @last_play[:x] = Random.rand(0..@board.width)
    @last_play[:y] = Random.rand(0..@board.height)
    @last_play[:command] = "UN"

    return @last_play
  end

  def repeat_last_play?
    return false if @last_play.nil?
    x = @last_play[:x]
    y = @last_play[:y]
    cmd = @last_play[:command]
    return true if Interpreter.
                    command_matches_state?(cmd,@board.cell(x,y))
    return false
  end

  def set_attributes
    command = @last_message[0]
    case command
    when BOARD_STATUS
      if @board.nil?
        @board = Board.new do |board|
          board.height = @last_message[1][1]
          board.width = @last_message[1][2]
          board.cells = @last_message[1][3]
        end
        @logger.debug "Agent: h = #{@board.height}, w = #{@board.width}"
      elsif @last_message[1][4] != nil
        @board.mines = @last_message[1][4]
      end
      @board.cells = @last_message[1][3]
    end
  end

  
end

