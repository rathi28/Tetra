class RemoveOfferDataDetail < ActiveRecord::Migration
  def change
  	drop_table :offer_data_details 
  end
end
