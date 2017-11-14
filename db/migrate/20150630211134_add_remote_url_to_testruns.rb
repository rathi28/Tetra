class AddRemoteUrlToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :remote_url, :string
  end
end
