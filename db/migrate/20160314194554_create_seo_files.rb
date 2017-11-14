class CreateSeoFiles < ActiveRecord::Migration
  def change
    create_table :seo_files do |t|
      t.string :filename
      t.string :domain
      t.string :targeturl
      t.text :valid_content

      t.timestamps
    end
  end
end
