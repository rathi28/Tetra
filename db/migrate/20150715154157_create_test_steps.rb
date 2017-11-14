class CreateTestSteps < ActiveRecord::Migration
  def change
    create_table :test_steps do |t|
      t.integer :testrunid
      t.string :expected
      t.string :actual
      t.integer :result
      t.integer :errorcode

      t.timestamps
    end
  end
end
