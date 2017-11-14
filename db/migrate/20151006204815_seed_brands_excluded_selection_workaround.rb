class SeedBrandsExcludedSelectionWorkaround < ActiveRecord::Migration
  def up
  	BrandsExcludedSelectionWorkaround.create brand: 'wen'
  	BrandsExcludedSelectionWorkaround.create brand: 'drdenese'
  	BrandsExcludedSelectionWorkaround.create brand: 'sheercover'
  	BrandsExcludedSelectionWorkaround.create brand: 'xout'
  end

  def down
  	BrandsExcludedSelectionWorkaround.all.destroy_all
  end
end
