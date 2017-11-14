class CreatePixelTests < ActiveRecord::Migration
  def change
    create_table :pixel_tests do |t|
      t.string :testname
      t.string :brand

      t.timestamps
    end
  end
end
