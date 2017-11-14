class AddKitnamesToTestrun < ActiveRecord::Migration
  def change
    add_column :testruns, :kitnames, :string
  end
end
