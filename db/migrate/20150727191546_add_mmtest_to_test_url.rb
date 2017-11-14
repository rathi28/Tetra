class AddMmtestToTestUrl < ActiveRecord::Migration
  def change
    add_column :test_urls, :mmtest, :text
  end
end
