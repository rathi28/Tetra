module ScheduleHelper

	##
	#
	def handle_recurring_schedule_failure(action, past_tense)
		begin
			yield
			flash[:success] = "Recurring Test Run #{past_tense}"
 		rescue => e
	      flash[:danger] = "Failed to #{action} Test"
	    end
	end
	
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
