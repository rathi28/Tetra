class CreatePageIdentifiers < ActiveRecord::Migration
  def change
    create_table :page_identifiers do |t|
      t.string :page
      t.string :value
      t.timestamps
    end
  end
end
