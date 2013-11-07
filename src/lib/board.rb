class Board

  include Enumerable

  attr_accessor :mines, :cells, :my_flags, :enemy_flags,:width, :height


  def initialize(width = nil,height = nil,mines = nil,cells = nil)
    @width = width
    @height = height
    @mines = mines
    @cells = cells
    @my_flags = 0
    @enemy_flags = 0
    yield self if block_given?
  end

  def cells=(new_cells)
    @cells = new_cells
    @height = new_cells.size
    @width= new_cells[0].size
  end

  def to_s
    ret = "\n"
    height.times do |i|
      width.times do |j|
        ret << @cells[i][j]
      end
      ret << "\n"
    end
    ret
  end

  def cell(x_coord,y_coord)
    unless x_coord >= @cells.size or x_coord >= @cells[0].size or
        x_coord < 0 or y_coord < 0
      return @cells[x_coord][y_coord]
    end
    return nil
  end

  def each(&block)
    @cells.flatten.each(&block)
  end
  
  def each_neighbour(x_coord,y_coord)
    [-1,0,1].each do |x|
      [-1,0,1].each do |y|
        nx = x_coord + x
        ny = y_coord + y
        unless cell(nx,ny).nil? or (x == 0  and y == 0)
          yield cell(nx,ny), nx, ny
        end
      end
    end
  end
end
