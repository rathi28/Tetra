class AddSuiteTypeToPixelTest < ActiveRecord::Migration
  def change
    add_column :pixel_tests, :suitetype, :string
  end
end
