class AddValidationsToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :vitamin_pricing, :string
    add_column :testruns, :cart_language, :text
    add_column :testruns, :cart_title, :string
    add_column :testruns, :total_pricing, :string
    add_column :testruns, :subtotal_price, :string
  end
end
