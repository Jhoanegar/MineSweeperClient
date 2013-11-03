#Handles the text<-> object conversion
class Interpreter
	
	RESPONSE_REG = /^\(REG (OK|NO)\s?(P1|P2)?\)+/
	attr_reader :response

  def	connect_command(player_name="MICHIGAN")
		"(REG #{player_name})"
	end

	def decode(message)
		case message
		when RESPONSE_REG
			if $1 == "OK" 
				@resṕonse = $2
				@success = true
			elsif $1 == "NO"
				@success = false
			end
		end
	end

	def success?
		@success
	end
end
