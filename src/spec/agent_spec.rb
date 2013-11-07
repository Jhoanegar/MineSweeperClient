require_relative 'spec_helper'

describe Agent do
  before(:each) do
    logger = double()
    logger.stub(:debug)
    @logger = logger
  end

  # it 'should return a random play' do
    # agent = Agent.new(@logger)
    # message = "(BE 1 3 3 C C C C C C C C C)"
    # agent.play(message).should == "Hola"
  # end

  it 'should set its board correctly' do
    agent =  Agent.new(@logger)
    message = ["BE",[10, 4, 3,
               [["00","01","02"],["10","11","12"],
                ["20","21","22"],["30","31","32"]]]]
    agent.send(:last_message=, message)
    agent.set_attributes
    agent.send(:board).cells.should == 
               [["00","01","02"],["10","11","12"],
                ["20","21","22"],["30","31","32"]]
  end

  it 'should get a random play the first time' do
    agent = Agent.new(@logger)
    message = ["BE",[10, 4, 3,
               [["00","01","02"],["10","11","12"],
                ["20","21","22"],["30","31","32"]]]]
    agent.play(message).should =~ Interpreter::COMMAND_UNCOVER
  end
 
  it 'should produce a random uncover withing the given bounds' do
    agent = Agent.new(@logger)
    message = ["BE",[10, 4, 3,
               [["C","C","C"],["C","C","C"],
                ["C","C","C"],["C","C","C"]]]]
    play = agent.play(message)
    play.should =~ Interpreter::COMMAND_UNCOVER
  end
end
