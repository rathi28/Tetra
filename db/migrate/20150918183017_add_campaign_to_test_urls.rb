class AddCampaignToTestUrls < ActiveRecord::Migration
  def change
    add_column :test_urls, :campaign, :string
  end
end
