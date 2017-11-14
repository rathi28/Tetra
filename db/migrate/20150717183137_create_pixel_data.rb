class CreatePixelData < ActiveRecord::Migration
  def change
    create_table :pixel_data do |t|
      t.string :pixel_handle
      t.integer :expected_state
      t.references :test_url, index: true

      t.timestamps
    end
  end
end
