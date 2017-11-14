class CreateTestUrls < ActiveRecord::Migration
  def change
    create_table :test_urls do |t|
      t.text :url
      t.text :appendstring
      t.string :mode
      t.integer :testdata_id
      t.string :page_type

      t.timestamps
    end
  end
end
