class AddPixelNameToPixelTest < ActiveRecord::Migration
  def change
    add_column :pixel_tests, :pixel_name, :text
  end
end
