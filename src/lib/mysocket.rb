require 'socket'
class MySocket < UDPSocket
  DEFAULT_SERVER_ADDRESS = "127.0.0.1"
  DEFAULT_SERVER_PORT = 4444
  DEFAULT_CLIENT_PORT = 4445
  def initialize(logger,
                 server = {:address=>DEFAULT_SERVER_ADDRESS,:port => DEFAULT_SERVER_PORT},
                 client = {:address=>DEFAULT_SERVER_ADDRESS,:port => DEFAULT_CLIENT_PORT})
    super(Socket::AF_INET)
    bind(client[:address],client[:port])
    @server_address = server[:address]
    @server_port = server[:port]
    @log = logger
  end
  
  def listen
    re = recvfrom(65536)
    @log.info "Received #{re[0]} from #{re[1][2]}:#{re[1][1]}"
    return re[0]
  end

  def send(message)
    super message, 0, @server_address, @server_port
    @log.info "Sent #{message} to #{@server_address}:#{@server_port}"
  end

end
