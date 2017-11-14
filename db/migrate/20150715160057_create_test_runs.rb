class CreateTestRuns < ActiveRecord::Migration
  def change
    create_table :test_runs do |t|
      t.string :testtype
      t.text :url
      t.text :remote_url
      t.string :runby
      t.float :runtime
      t.integer :result
      t.string :brand
      t.string :campaign
      t.string :platform
      t.string :browser
      t.string :env
      t.text :scripterror
      t.integer :lock_test
      t.string :workerassigned
      t.string :driver
      t.string :driverplatform
      t.integer :suiteid
      t.datetime :datetime
      t.text :comments
      t.datetime :scheduledate

      t.timestamps
    end
  end
end
