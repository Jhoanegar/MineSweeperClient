require 'set'
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

  def cell(*args)
    if args[0].respond_to?(:x) and args[0].respond_to?(:y)
      x = args[0].x
      y = args[0].y
    elsif args.size == 2
      x = args[0]
      y = args[1]
    end
    unless x >= self.width or y >= self.height or
        x < 0 or y < 0
      return @cells[y][x][-1]
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
 
  def each_neighbour(*args)
    connections = [-1,0,1]
    if args[0].respond_to?(:x) and args[0].respond_to?(:y)
      x_coord = args[0].x
      y_coord = args[0].y
    elsif args.size == 2
      x_coord = args[0]
      y_coord = args[1]
    end
    connections.each do |x|
      connections.each do |y|
        nx = x_coord + x
        ny = y_coord + y
        nc = cell(nx,ny)
        unless nc.nil? or (x == 0  and y == 0)
          if nc[-1] =~ /\d/
            yield nc.to_i, nx, ny
          else
            yield nc, nx, ny
          end
        end
      end
    end
  end
 
end
