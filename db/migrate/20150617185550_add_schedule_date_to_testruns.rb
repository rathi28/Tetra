class AddScheduleDateToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :scheduledate, :datetime
  end
end
