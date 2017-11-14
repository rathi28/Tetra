class AddIsTestPanelToCampaign < ActiveRecord::Migration
  def change
  	add_column :campaigns, :is_test_panel, :boolean
  end
end
