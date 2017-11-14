class AddEnvironmentToPixelTests < ActiveRecord::Migration
  def change
    add_column :pixel_tests, :environment, :string
  end
end
