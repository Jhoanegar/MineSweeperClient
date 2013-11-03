#andles all the components
require_relative '../minesweeperclient'
class Client
	
	def initialize(socket = nil)
		@connected = false
		@socket = socket || MySocket.new
		@interpreter = Interpreter.new
	end

	def start
		@socket.send(@interpreter.connect_command)
		@interpreter.decode(@socket.listen)
		if @interpreter.success? then
			@connected = true
			@player_name = @interpreter.response
		else
			raise "Can't connect to the server"	
		end
	end

	def connected?
		@connected
	end
end
