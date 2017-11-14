class AddSaspricingToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :saspricing, :text
  end
end
