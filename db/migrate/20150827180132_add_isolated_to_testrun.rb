class AddIsolatedToTestrun < ActiveRecord::Migration
  def change
    add_column :testruns, :isolated, :integer
  end
end
