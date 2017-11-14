class AddLockTestToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :lock_test, :integer
  end
end
