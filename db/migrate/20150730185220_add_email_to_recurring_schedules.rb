class AddEmailToRecurringSchedules < ActiveRecord::Migration
  def change
    add_column :recurring_schedules, :email, :text
  end
end
