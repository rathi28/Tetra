class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string :name
      t.string :ip
      t.integer :pixel
      t.integer :buyflow
      t.integer :offercode
      t.integer :scheduled

      t.timestamps
    end
  end
end
