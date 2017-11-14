class AddLastRunDateToRecurringSchedule < ActiveRecord::Migration
  def change
    add_column :recurring_schedules, :lastrundate, :date
  end
end
