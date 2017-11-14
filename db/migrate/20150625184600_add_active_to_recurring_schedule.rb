class AddActiveToRecurringSchedule < ActiveRecord::Migration
  def change
    add_column :recurring_schedules, :active, :integer
  end
end
