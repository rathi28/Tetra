class AddMmtestToPixelTests < ActiveRecord::Migration
  def change
    add_column :pixel_tests, :mmtest, :text
  end
end
