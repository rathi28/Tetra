class AddPixelNameToPixelData < ActiveRecord::Migration
  def change
    add_column :pixel_data, :pixel_name, :text
  end
end
