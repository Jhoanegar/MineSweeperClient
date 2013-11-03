require 'socket'
require 'logger'
class MySocket < UDPSocket
	DEFAULT_ADDRESS = "127.0.0.1"
	DEFAULT_PORT = 4444
	def initialize(address = DEFAULT_ADDRESS,port = DEFAULT_PORT)
		super(Socket::AF_INET)
		bind("localhost",5555)
		@server_address = address
		@server_port = port
		@log = Logger.new('log.txt')

		@log.level = Logger::DEBUG
		@log.debug "Client created successfully."
	end
	
	def listen
		re = recvfrom(65535)
		@log.debug "Received #{re[0]} from #{re[1][2]}:#{re[1][1]}"
		return re[0]
	end

	def send(message)
		super message, 0, @server_address, @server_port
	end

end
