class AddPixelSuiteToRecurringSchedules < ActiveRecord::Migration
  def change
    add_column :recurring_schedules, :pixel_suite, :integer
  end
end
