##
# enhanced error handling and exceptions for the Grotto
module BetterErrors

	##
	# Catch a failed action, but don't propogate the problem to test level.
	def catch_and_display_error
		begin
			yield
		rescue => e
			Rails.logger.info e.message
			if(e.backtrace)
				Rails.logger.info e.backtrace
			end
		end
	end

	##
	# Catch a failed action, but don't propogate the problem to test level.
	# This version only displays a message
	def catch_simple
		begin
			yield
		rescue => e
			Rails.logger.info e.message
		end
	end

	##
	# Record Error to the database (without recording test run)
	def log_error_to_database(e)
		error_obj = ErrorMessage.new()
		catch_simple do
	    error_obj.class_name = e.class.to_s
	  end
	  catch_simple do
	    error_obj.message = e.message
	  end
	  catch_simple do
	    error_obj.backtrace = e.backtrace.join("\n")
	  end
    error_obj.save!
	end
end