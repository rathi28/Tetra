class AddRealmToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :realm, :string
  end
end
