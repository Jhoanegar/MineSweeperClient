require_relative './spec_helper'

describe Interpreter do
  it 'should match SF to F' do
    command = "SF"
    cell = "PLAYER_1F"
    Interpreter.command_matches_state?(command,cell).should == true
  end
  
  it 'should not match SF TO E' do
    command = "SF"
    cell = "C"
    Interpreter.command_matches_state?(command,cell).should == false 
  end

  it 'should match RF to C' do
    command = "RF"
    cell = "PLAYER_1C"
    Interpreter.command_matches_state?(command,cell).should == true
  end

  it 'should match UN to any number' do
    command = "UN"
    cell = "PLAYER_1#{Random.rand(1..8)}"
    Interpreter.command_matches_state?(command,cell).should == true
  end

  it 'should match UN to E' do
    command = "UN"
    cell = "PLAYER_1E"
    Interpreter.command_matches_state?(command,cell).should == true
  end

  it 'should not match UN to C' do
    command = "UN"
    cell = "C"
    Interpreter.command_matches_state?(command,cell).should == false
  end

  it 'should not match UN to F' do
    command = "UN"
    cell = "PLAYER_1F"
    Interpreter.command_matches_state?(command,cell).should == false
  end
end


