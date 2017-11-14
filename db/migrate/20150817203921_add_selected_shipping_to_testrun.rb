class AddSelectedShippingToTestrun < ActiveRecord::Migration
  def change
    add_column :testruns, :selected_shipping, :string
  end
end
