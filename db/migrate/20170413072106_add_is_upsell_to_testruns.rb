class AddIsUpsellToTestruns < ActiveRecord::Migration
  def change
  	add_column :testruns, :is_upsell, :boolean, default: 0, null: false
  end
end
