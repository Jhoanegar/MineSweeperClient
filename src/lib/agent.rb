#Handles the logic 
require_relative './board'
class Agent
  def initialize(logger)
    @logger = logger
    @board = nil
    @last_play = ["UN",-1,-1]
    @last
  end
  def play(arg)
    @last_play[1] += 1
    @last_play[2] += 1
    return "(#{@last_play[0]} #{@last_play[1]} #{@last_play[2]})"
  end
end
