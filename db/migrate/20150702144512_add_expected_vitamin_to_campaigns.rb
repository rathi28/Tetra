class AddExpectedVitaminToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :expectedvitamin, :string
  end
end
