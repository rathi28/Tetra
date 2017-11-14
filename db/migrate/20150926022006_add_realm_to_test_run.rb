class AddRealmToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :realm, :string
  end
end
