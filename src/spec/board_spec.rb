require_relative './spec_helper'

describe Board do
  it 'should initialize correctly' do
    board = Board.new do |new_board|
      new_board.mines = 4
      new_board.cells = [["C","C","C"],["C","C","C"],
               ["C","C","C"],["C","C","C"]]
      end
    
    board.width.should == 3
    board.height.should == 4
    board.mines.should == 4
    board.cells.should have(4).items
    board.cells.each { |e| e.should have(3).items }
  end

  it 'should return the correct cell' do
    board = Board.new() {|b| b.cells = [[1,2],[3,4]] }
    board.cell(1,1).should be 4
  end

  it 'should return nil if the cell is out of bounds' do
    board = Board.new() {|b| b.cells = [[1,2],[3,4]] }
    board.cell(4,4).should be nil
    board.cells.should have(2).items
  end

  it 'should yield all the cells' do
    board = Board.new() {|b| b.cells = [[1,2],[3,4]] }
    results = board.map(&:to_i)
    results.should == [1,2,3,4]
  end

  it 'should yield all the neighbours of a cell' do
    board = Board.new {|b| b.cells = [
                                     [1,2,3],
                                     [4,5,6],
                                     [7,8,9]] }
    results = []
    board.each_neighbour(1,1) do |cell,nx,ny|
      results << cell
    end
    results.should == [1,2,3,4,6,7,8,9]
  end
  
  it 'should only yield the neighbours within range' do
    board = Board.new {|b| b.cells = [
                                     [1,2,3],
                                     [4,5,6],
                                     [7,8,9]] }
   

    results = []
    board.each_neighbour(0,1) do |cell,nx,ny|
      results << cell
    end
    results.should == [1,3,4,5,6]
  end 
  
  it 'should parse and get any cell' do
    logger = double()
    logger.stub(:debug)
    inter = Interpreter.new(logger)
    message = "BE 5 10 8 C C C C C C C C C C C C C C C P2E C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C P2E C C C C C C C C C C C C C C C C C C C C C C C C C C C"
    cells = inter.parse_board(message)[1][3]
    board = Board.new {|b| b.cells = cells}
    board.height.should == 10
    board.width.should == 8
    board.cell(8,6).should == "C"
  end
    
end


