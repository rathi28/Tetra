class AddShippingConfValToTestrun < ActiveRecord::Migration
  def change
    add_column :testruns, :shipping_conf_val, :string
  end
end
