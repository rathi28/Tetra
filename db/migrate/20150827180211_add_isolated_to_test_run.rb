class AddIsolatedToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :isolated, :integer
  end
end
