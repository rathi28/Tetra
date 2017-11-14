class AddUciSasToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :uci_sas, :string
  end
end
