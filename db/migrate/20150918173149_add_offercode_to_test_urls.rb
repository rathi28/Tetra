class AddOffercodeToTestUrls < ActiveRecord::Migration
  def change
    add_column :test_urls, :offercode, :string
  end
end
