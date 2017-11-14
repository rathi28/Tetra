class AddPricesToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :price_a, :string
    add_column :testruns, :price_e, :string
  end
end
