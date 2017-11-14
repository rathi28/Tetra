class AddEmailRandomToTestSuites < ActiveRecord::Migration
  def change
  	add_column :test_suites, :email_random, :boolean
  end
end
