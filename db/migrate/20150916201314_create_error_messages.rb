class CreateErrorMessages < ActiveRecord::Migration
  def change
    create_table :error_messages do |t|
      t.text :message
      t.text :backtrace
      t.text :class_name
      t.references :testrun, index: true
      t.references :test_run, index: true

      t.timestamps
    end
  end
end
