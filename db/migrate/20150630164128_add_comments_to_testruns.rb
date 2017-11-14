class AddCommentsToTestruns < ActiveRecord::Migration
  def change
  	add_column :testruns, :comments, :text
  end
end
