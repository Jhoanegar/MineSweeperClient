class Play
  attr_accessor :command

  def initialize(x=nil,y=nil,cmd=nil)
    @coords = Coords.new(x.to_i,y.to_i)
    @command = cmd
    yield self if block_given?
  end

  def to_command
    "(#{command} #{@coords.x} #{@coords.y})"
  end
  
  def == other
    if @coords == other.coords and @command == other.command
      return true 
    else
      return false
    end
  end

  def x=(new_x)
    @coords.x = new_x.to_i
  end

  def y=(new_x)
    @coords.y = new_x.to_i
  end

  def x
    @coords.x
  end

  def y
    @coords.y
  end

  def coords
    @coords
  end

  class Coords < Struct.new(:x,:y)
  end
end


