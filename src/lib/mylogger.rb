require 'logger'
require 'date'
module MyLogger
  def MyLogger.new_logger(file_name, level = Logger::DEBUG)
    file = File.new(file_name,"w")
    log = Logger.new(file)
    log.level = level
    log.formatter = proc do |severity, datetime, prog_name, msg|
      date = datetime.strftime("%T,%L")
      "[#{date}] #{severity} -- :\n  #{msg}\n"
    end
    log.debug "Logger created"
    return log
  end
end
