class AddCustomOfferToRecurringSchedule < ActiveRecord::Migration
  def change
    add_column :recurring_schedules, :customoffer, :string
  end
end
