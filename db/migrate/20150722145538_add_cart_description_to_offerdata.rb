class AddCartDescriptionToOfferdata < ActiveRecord::Migration
  def change
    add_column :offerdata, :cart_description, :text
  end
end
