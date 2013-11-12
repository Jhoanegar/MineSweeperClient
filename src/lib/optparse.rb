require 'ostruct'
require 'optparse'
class OptParse
  VALID_IPV4_ADDRESS = /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
  VALID_PORT = /^\d{1,5}$/
  def self.valid_server?(arr)
    if arr.first == "localhost" or arr.first =~ VALID_IPV4_ADDRESS
      return true if arr.last =~ VALID_PORT
    end
    return false
  end

  def self.parse(args)
    options = OpenStruct.new
    options.host = OpenStruct.new
    options.server = OpenStruct.new 
    options.host.address = "127.0.0.1"
    options.host.port = 4445 
    options.server.address = "127.0.0.1"
    options.server.port = 4444
    options.file = 'log.log'
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [CONFIG]"

      opts.on("-l", "--log LOG_FILE",
             "The events of the game will be logged to LOG_FILE",
             "  Default: 'log.log'") do |log|
             options.file = log
      end

      opts.on("-p", "--port PORT",
              "The client will bind itself to PORT.",
              "  Default: 4445") do |port|
        options.host.port = port
      end
      
      opts.on("-s", "--server ADDRESS:PORT",
              "The client will comunicate to ADDRESS:PORT.",
              "  Default: 127.0.0.1:4444") do |server|
              arr = server.split(":")
              if arr.size != 2
                raise OptionParser::MissingArgument
              end
              raise OptionParser::InvalidArgument unless valid_server? arr
              options.server.address = arr.first
              options.server.port = arr.last
      end
    end

    opt_parser.parse!(args)
    options
  end 
  
  def self.config_object(buffer)
    begin
      opt = OptParse.parse(buffer)
    rescue OptionParser::MissingArgument,OptionParser::InvalidArgument => e
      case e.message[-1]
      when "s"
        puts "#{__FILE__}: The correct format is ADDRESS:PORT for instance '127.0.0.1:4444'."
        puts " See '#{__FILE__} -h' for help."
      when "p" 
        puts "#{__FILE__}: The port should be an integer of up to 5 digits."
        puts " See '#{__FILE__} -h' for help."
      end
    rescue OptionParser::InvalidOption => e
      puts "#{__FILE__}: Unknown option."
      puts " See '#{__FILE__} -h' for help."
    ensure
    end
  end

end

