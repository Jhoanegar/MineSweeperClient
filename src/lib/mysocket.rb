require 'socket'
class MySocket < UDPSocket
  def initialize(logger, config)
    @log = logger
    @server_address = config.server.address
    @server_port = config.server.port

    @log.info "Socket: Binded to #{config.host.address}:#{config.host.port}" 
    @log.info "Socket: Server at #{@server_address}:#{@server_port}" 

    super(Socket::AF_INET)
    bind(config.host.address,config.host.port)

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
