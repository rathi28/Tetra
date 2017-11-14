class CreateBrandsExcludedSelectionWorkarounds < ActiveRecord::Migration
  def change
    create_table :brands_excluded_selection_workarounds do |t|
      t.string :brand

      t.timestamps
    end
  end
end
