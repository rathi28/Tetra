class CreateErrorCodes < ActiveRecord::Migration
  def change
    create_table :error_codes do |t|
      t.string :human_name
      t.integer :errorcode

      t.timestamps
    end
  end
end
