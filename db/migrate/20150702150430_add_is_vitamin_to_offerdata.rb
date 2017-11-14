class AddIsVitaminToOfferdata < ActiveRecord::Migration
  def change
    add_column :offerdata, :isvitamin, :integer
  end
end
