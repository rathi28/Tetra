class AddConfoffercodeToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :confoffercode, :string
  end
end
