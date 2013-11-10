class Play
  attr_accessor :command
  attr_reader :x, :y

  def initialize(x=nil,y=nil,cmd=nil)
    @x = x.to_i
    @y = y.to_i
    @command = cmd
    yield self if block_given?
  end

  def x=(new_x)
    @x = new_x.to_i
  end

  def y=(new_y)
    @y = new_y.to_i
  end
 
  def to_command
    "(#{command} #{y} #{x})"
  end
  
  def == other
    return true if @x == other.x and 
                   @y == other.y and @command == other.command

    return false
  end
end
