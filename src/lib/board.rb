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
    
    ret = "\n "
    width.times {|t| ret << (t % 10).to_s}
    ret << "\n"
    height.times do |i|
      ret << (i % 10).to_s
      width.times do |j|
        ret << case @cells[i][j].chars.last
               when /C/
                 "\u2588".encode("utf-8")
               when /F/
                 "*"
                 # "\u2713".encode("utf-8")
               # when /1/
               #   "\u278A".encode("utf-8")
               # when /2/
               #   "\u278B".encode("utf-8")
               # when /3/
               #   "\u278C".encode("utf-8")
               # when /4/
                 # "\u278C".encode("utf-8")
               when /E/
                 "-"
               else
                 @cells[i][j].chars.last
               end
               
      end
      ret << "\n"
    end
    ret
  end

  def cell(x_coord,y_coord)
    unless x_coord >= self.width or y_coord >= self.height or
        x_coord < 0 or y_coord < 0
      return @cells[y_coord][x_coord][-1]

    end
    return nil
  end

  def each
    height.times do |y|
      width.times do |x|
        yield cell(x,y)[-1], x, y
      end
    end
  end
  
  def each_neighbour(x_coord,y_coord)
    [-1,0,1].each do |x|
      [-1,0,1].each do |y|
        nx = x_coord + x
        ny = y_coord + y
        unless cell(nx,ny).nil? or (x == 0  and y == 0)
          yield cell(nx,ny)[-1].to_i, nx, ny if cell(nx,ny)[-1] =~ /\d/
          yield cell(nx,ny)[-1], nx, ny if cell(nx,ny)[-1] =~ /[^\d]/
        end
      end
    end
  end
end
