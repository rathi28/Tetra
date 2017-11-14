class AddSaspricesToTestrun < ActiveRecord::Migration
  def change
    add_column :testruns, :sasprices, :string
  end
end
