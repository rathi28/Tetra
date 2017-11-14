class AddStatusToTestRuns < ActiveRecord::Migration
  def change
    add_column :test_runs, :status, :string
  end
end
