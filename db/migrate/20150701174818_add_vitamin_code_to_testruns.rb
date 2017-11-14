class AddVitaminCodeToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :vitamincode, :string
  end
end
