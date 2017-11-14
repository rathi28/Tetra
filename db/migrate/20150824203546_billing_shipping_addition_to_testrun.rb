class BillingShippingAdditionToTestrun < ActiveRecord::Migration
  def change
  	add_column :testruns, :billing_shipping_hash, :text
  end
end
