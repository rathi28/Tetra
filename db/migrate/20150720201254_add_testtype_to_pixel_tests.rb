class AddTesttypeToPixelTests < ActiveRecord::Migration
  def change
    add_column :pixel_tests, :testtype, :string
  end
end
