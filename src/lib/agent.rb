#Handles the logic 
require_relative './board'
class Agent
  def initialize(logger)
    @logger = logger
    @board = nil
		@last_message = nil
    @last_play = nil 
    @next_plays = []
  end

  def play(message)
		@logger.debug "#{self.class} Received #{message.inspect}"
		@last_message = message
		set_attributes
#		@logger.debug "#{self.class}: The board is: #{@board}"
		unless @next_plays.empty?
			@last_play = @next_plays.last
			return @next_plays.pop
		end
		@last_play =  "(UN #{Random.rand(0..@board.height)} #{Random.rand(0..@board.width)})"
		return @last_play
  end

	def set_attributes
		command = @last_message[0]
		case command
		when "BE"
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

