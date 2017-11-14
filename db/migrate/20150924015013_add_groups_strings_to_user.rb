class AddGroupsStringsToUser < ActiveRecord::Migration
  def change
    add_column :users, :group_strings, :string
  end
end
