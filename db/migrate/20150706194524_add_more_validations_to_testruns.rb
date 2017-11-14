class AddMoreValidationsToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :billname, :string
    add_column :testruns, :billemail, :string
    add_column :testruns, :shipaddress, :string
    add_column :testruns, :billaddress, :string
  end
end
