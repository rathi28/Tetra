class FixSuiteIdRelationship < ActiveRecord::Migration
  def change
  	rename_column :test_runs, :suiteid, :test_suites_id
  	rename_column :testruns, :SuiteID, :test_suites_id
  end
end
