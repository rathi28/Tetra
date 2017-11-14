class AddRealmToTestSuites < ActiveRecord::Migration
  def change
    add_column :test_suites, :realm, :string
  end
end
