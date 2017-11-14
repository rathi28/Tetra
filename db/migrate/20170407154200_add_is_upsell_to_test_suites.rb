class AddIsUpsellToTestSuites < ActiveRecord::Migration
  def change
  	add_column :test_suites, :is_upsell, :boolean
  end
end
