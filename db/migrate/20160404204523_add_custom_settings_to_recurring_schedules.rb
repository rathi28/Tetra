class AddCustomSettingsToRecurringSchedules < ActiveRecord::Migration
  def change
  	add_column :recurring_schedules, :custom_settings, :text
  end
end
