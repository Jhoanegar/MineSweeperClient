class Board
  attr_accessor :width, :height, :mines, :cells
  def initialize(width = nil,height = nil,mines = nil,cells = nil)
    @width = width
    @height = height
    @mines = mines
    @cells = cells
    @my_flags = 0
    @enemy_flags = 0
    yield self if block_given?
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
    return @cells[x_coord][y_coord]
  end
end
