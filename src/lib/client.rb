#andles all the components
class Client
  
  def initialize(logger, socket = nil)
    @logger = logger
    @connected = false
    @socket = socket || MySocket.new(logger)
    @interpreter = Interpreter.new(logger)
    @agent = Agent.new(logger)
    @player_name = ""
    @win = false
  end

  def start
    @socket.send(@interpreter.connect_command)
    @interpreter.decode(@socket.listen)
    if @interpreter.response then
      @connected = true
      @player_name = @interpreter.response
      @logger.info "#{self.class}: Connected to server, name: #{@player_name}"
      run
    else
      raise "Can't connect to the server" 
    end
  end

  def run
    while true
      @interpreter.decode(@socket.listen)
      case @interpreter.response[0]
      when "ON"
        @agent.score = @interpreter.response[1]
        next
      when "FIN"
        @win = true if @interpreter.response[1][0] == "W#{@player_name}"
        break
      when "SCORE"
        @agent.score = @interpreter.response
      else
        @socket.send(@agent.play(@interpreter.response))
      end
    end
    @logger.info "Client: Game Finished"
    celebrate! if @win
  end

  def connected?
    @connected
  end

  def celebrate!
    rain = Rain.new
    rain.play
  end
end
