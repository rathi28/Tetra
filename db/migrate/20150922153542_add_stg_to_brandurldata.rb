class AddStgToBrandurldata < ActiveRecord::Migration
  def change
    add_column :brandurldata, :stg, :string
  end
end
