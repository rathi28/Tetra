class AddProductToOfferdata < ActiveRecord::Migration
  def change
    add_column :offerdata, :product, :string
  end
end
