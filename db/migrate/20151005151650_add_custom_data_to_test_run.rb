class AddCustomDataToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :custom_data, :string
  end
end
