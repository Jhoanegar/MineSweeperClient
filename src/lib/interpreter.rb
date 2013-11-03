#Handles the text<-> object conversion
class Interpreter
	
	RESPONSE_REG = /^\(REG (OK|NO)\s?(P1|P2)?\)+/
	RESPONSE_GAME_STATE = /\(GE\s(\d)+\s(ON|SCORE|FIN).*\)/
	attr_reader :response

  def	connect_command(player_name="MICHIGAN")
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
				@response = ["SCORE",message.remove_parenthesis.split(" ")[3]]
			elsif $2 == "FIN"
				@response = ["FIN",message.remove_parenthesis.split(" ")[-4..-1]]
			end
		else
			@response = "UNKNOWN COMMAND"
		end

	end

end
