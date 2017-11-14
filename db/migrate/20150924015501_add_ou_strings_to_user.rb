class AddOuStringsToUser < ActiveRecord::Migration
  def change
    add_column :users, :ou_strings, :string
    add_column :users, :name, :string
  end
end
