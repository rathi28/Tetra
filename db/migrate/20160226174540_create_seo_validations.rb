class CreateSeoValidations < ActiveRecord::Migration
  def change
    create_table :seo_validations do |t|
      t.string :realm
      t.boolean :is_core
      t.string :page_name
      t.string :validation_type
      t.text :value
      t.boolean :present

      t.timestamps
    end
  end
end
