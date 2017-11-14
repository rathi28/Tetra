class AddStgToOfferdata < ActiveRecord::Migration
  def change
    add_column :offerdata, :stg, :integer
  end
end
