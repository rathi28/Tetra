class AddOrderIdToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :order_id, :string
  end
end
