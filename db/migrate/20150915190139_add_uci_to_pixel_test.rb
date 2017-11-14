class AddUciToPixelTest < ActiveRecord::Migration
  def change
    add_column :pixel_tests, :uci, :string
  end
end
