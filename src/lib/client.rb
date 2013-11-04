#andles all the components
class Client
	
	def initialize(logger, socket = nil)
		@logger = logger
		@connected = false
		@socket = socket || MySocket.new(logger)
		@interpreter = Interpreter.new(logger)
		@agent = Agent.new(logger)
		@player_name = ""
	end

	def start
		@socket.send(@interpreter.connect_command)
		@interpreter.decode(@socket.listen)
		if @interpreter.response then
			@connected = true
			@player_name = @interpreter.response
			@logger.debug "#{self.class}: Connected to server"
			run
		else
			raise "Can't connect to the server"	
		end
	end

	def run
		
		while true
			 @interpreter.decode @socket.listen
			 next if @interpreter.response[0] == "ON"
			 break if @interpreter.response[0] == "FIN"
			 next_play = @agent.play @interpreter.response
			 @logger.debug "#{self.class}: I Will send #{next_play}"
			 @socket.send next_play
		end

	end

	def connected?
		@connected
	end
end
