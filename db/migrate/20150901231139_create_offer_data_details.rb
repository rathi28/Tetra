class CreateOfferDataDetails < ActiveRecord::Migration
  def change
    create_table :offer_data_details do |t|
      t.text :offer_title
      t.text :offerdesc
      t.integer :offerdatum_id

      t.timestamps
    end
  end
end
