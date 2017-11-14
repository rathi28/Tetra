class FixDatetimeNameTestRuns < ActiveRecord::Migration
  def change
  	def change
	    rename_column :test_run, :datetime, :DateTime
	  end
  end
end
