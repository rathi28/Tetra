class AddDummyBooleanToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :dummyboolean, :boolean
  end
end
