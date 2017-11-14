class AddVitaminexpectedToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :vitaminexpected, :string
  end
end
