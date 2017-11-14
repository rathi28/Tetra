class AddRealmToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :realm, :string
  end
end
