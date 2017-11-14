class FixQuanityToQuantity < ActiveRecord::Migration
  def change
    rename_column :testruns, :cart_quanity, :cart_quantity
  end
end
