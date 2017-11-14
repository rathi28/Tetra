module TestrunHelper
	def get_color(testrun)
		case testrun["result"]
		when "Pass"
			return "success"
		when "Fail"
			return "danger"
		when "waiting"
			return "info"
		else
			return ""
		end
	end
end
