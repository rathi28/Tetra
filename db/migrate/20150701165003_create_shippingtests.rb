class CreateShippingtests < ActiveRecord::Migration
  def change
    create_table :shippingtests do |t|
      t.string :shippingtype
      t.string :actual
      t.string :expected
      t.references :testrun, index: true

      t.timestamps
    end
  end
end
