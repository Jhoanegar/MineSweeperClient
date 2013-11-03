class Board
  def initialize(width,height,mines)
    @width = width
    @height = height
    @total_mines = mines
    @my_flags = 0
    @enemy_flags = 0
    @cells = []
  end
end