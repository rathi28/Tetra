class AddEmailFieldToTestSuites < ActiveRecord::Migration
  def change
    add_column :test_suites, :emailnotification, :string
  end
end
