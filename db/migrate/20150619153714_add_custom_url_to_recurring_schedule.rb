class AddCustomUrlToRecurringSchedule < ActiveRecord::Migration
  def change
    add_column :recurring_schedules, :customurl, :string
  end
end
