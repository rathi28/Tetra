class AddScheduledateToTestSuites < ActiveRecord::Migration
  def change
    add_column :test_suites, :scheduledate, :datetime
  end
end
