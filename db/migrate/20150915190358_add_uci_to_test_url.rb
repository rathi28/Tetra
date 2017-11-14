class AddUciToTestUrl < ActiveRecord::Migration
  def change
    add_column :test_urls, :uci, :string
  end
end
