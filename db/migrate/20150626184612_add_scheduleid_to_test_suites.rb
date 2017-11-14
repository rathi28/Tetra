class AddScheduleidToTestSuites < ActiveRecord::Migration
  def change
    add_column :test_suites, :scheduleid, :integer
  end
end
