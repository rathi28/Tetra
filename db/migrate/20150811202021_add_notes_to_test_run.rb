class AddNotesToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :Notes, :text
  end
end
