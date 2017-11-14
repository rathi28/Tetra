class AddRealmToRecurringSchedules < ActiveRecord::Migration
  def change
    add_column :recurring_schedules, :realm, :string
  end
end
