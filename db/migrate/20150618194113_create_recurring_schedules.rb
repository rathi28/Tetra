class CreateRecurringSchedules < ActiveRecord::Migration
  def change
    create_table :recurring_schedules do |t|
      t.string :name
      t.string :testtype
      t.string :weeklyday
      t.integer :dailyhour
      t.integer :dailyminute
      t.string :grcid
      t.integer :vanitylist
      t.integer :ucilist
      t.string :driver
      t.string :platform
      t.string :brand
      t.string :environment
      t.datetime :creationdate

      t.timestamps
    end
  end
end
