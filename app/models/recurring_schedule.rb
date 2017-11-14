##
# This is the model in charge of all the scheduled tests that run on a recurring basis
class RecurringSchedule < ActiveRecord::Base
	def self.get_day_of_week()
		Date::DAYNAMES[Time.now.wday]
	end
	
	def self.get_daily_tests()
		todays_tests = RecurringSchedule.where(:weeklyday => nil).where('lastrundate < ?', Date.today).where(:active => 1)
		tests_now = todays_tests.where('dailyhour <= ? AND dailyminute <= ?', Time.now.hour, Time.now.min)
	end

	def self.get_weekly_tests_for_today()
		todays_tests = RecurringSchedule.where(:weeklyday => get_day_of_week()).where('lastrundate < ?', Date.today).where(:active => 1)
		tests_now = todays_tests.where('dailyhour <= ? AND dailyminute <= ?', Time.now.hour, Time.now.min)
	end
end