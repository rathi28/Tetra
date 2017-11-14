class CreateActionLogs < ActiveRecord::Migration
  def change
    create_table :action_logs do |t|
      t.string :user
      t.string :action
      t.string :target
      t.datetime :time_of_action

      t.timestamps
    end
  end
end
