class AddSeoUrlColumns < ActiveRecord::Migration
  def change
  	add_column :test_urls, :realm, :string
  	add_column :test_urls, :is_core, :boolean
  end
end
