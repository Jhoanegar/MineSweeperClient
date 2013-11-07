#Handles the text<-> object conversion
class Interpreter
  
  RESPONSE_REG = /^\(REG (OK|NO)\s?(P1|P2)?\)+/
  RESPONSE_GAME_STATE = /\(GE\s(\d)+\s(ON|SCORE|FIN).*\)/
  RESPONSE_BOARD_STATE = /\((BE)\s(\d)+\s(\d)+\s(\d)+.*\)/
  COMMAND_UNCOVER = /\(UN\s(\d)+\s(\d)\)/
  attr_reader :response
  
  def self.command_matches_state?(command,cell)
    cell_state = cell.chars.last
    case command 
    when "UN"
      return true if cell_state =~ /.*[E\d]$/
    when "SF"
      return true if cell_state =~ /.*F$/
    when "RF"
      return true if cell_state =~ /.*C$/
    end
    false 
  end
    
  
  def initialize(logger)
    @logger = logger
  end

  def connect_command(player_name="MICHIGAN")
    "(REG #{player_name})"
  end

  def decode(message)
    case message

    when RESPONSE_REG
      if $1 == "OK" 
        @response = $2
      elsif $1 == "NO"
        @response = nil
      end

    when RESPONSE_GAME_STATE
      if $2 == "ON"
        @response = ["ON"]
      elsif $2 == "SCORE"
        @response = ["SCORE",message.remove_parenthesis.split(" ")[3].to_i]
      elsif $2 == "FIN"
        @response = ["FIN",
            message.remove_parenthesis.split(" ")[-4..-1]]
      end
    
    when RESPONSE_BOARD_STATE
      @response = parse_board(message.remove_parenthesis)
    else
      @response = "UNKNOWN COMMAND"
    end
    @logger.debug "#{self.class}: I decoded #{@response[0].inspect}"
    @response
  end

  def parse_board(message)
    command, cycle, n_rows, n_cols,cells = message.split(" ",5)
    board = build_board(cells,n_rows.to_i,n_cols.to_i)
    return [command,[cycle.to_i,n_rows.to_i,n_cols.to_i,board]]
  end

  def build_board(cells,rows,cols) 
    board = []
    cells = cells.split
    rows.times do |i|
      board << []
      cols.times do
        board[i] << cells.shift
      end
    end
    return board
  end
  
end

