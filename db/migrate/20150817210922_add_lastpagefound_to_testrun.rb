class AddLastpagefoundToTestrun < ActiveRecord::Migration
  def change
    add_column :testruns, :lastpagefound, :string
  end
end
