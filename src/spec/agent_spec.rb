require_relative 'spec_helper'

describe Agent do
  before(:each) do
    logger = double()
    logger.stub(:debug)
    @logger = logger
  end

  it 'should return a random play' do
    agent = Agent.new(@logger)
    message = "(BE 1 3 3 C C C C C C C C C)"
    agent.play(message).should == "Hola"
  end


end
