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
 
  def each_neighbour(x_coord,y_coord,connections = [[-1,0,1],[-1,0,1]])
    connections[0].each do |x|
      connections[1].each do |y|
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
 
  def each_straight_neighbour(x,y,&block)
    top = right = bottom = left = []
    each_top_neighbour(x,y).each{|cell,nx,ny| top << [cell,nx,ny]}
    each_left_neighbour(x,y).each{|cell,nx,ny| left << [cell,nx,ny]}
    each_right_neighbour(x,y).each{|cell,nx,ny| right << [cell,nx,ny]}
    each_bottom_neighbour(x,y).each{|cell,nx,ny| bottom << [cell,nx,ny]}
    neighbours = (top + left + right + bottom).to_set
    return neighbours

  end
 
  def method_missing(method_name, *args, &block)
    if method_name =~ /each_(.*)_neighbour/ and args.size == 2
      connections = case $1
                    when "top"
                      [[-1,0,1],[-1]]
                    when "left"
                      [[-1],[-1,0,1]]
                    when "right"
                      [[1],[-1,0,1]]
                    when "bottom"
                      [[-1,0,1],[1]]
                    else
                      super(method_name, args)
                    end
      each_neighbour(args[0], args[1],connections, &block) 
    else
      super(method_name, args)
    end
  end

end
