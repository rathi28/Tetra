class CreateVanityUciSuites < ActiveRecord::Migration
  def change
    create_table :vanity_uci_suites do |t|
      t.string :testname
      t.string :brand
      t.string :environment
      t.string :testtype
      t.string :group
      t.boolean :uci

      t.timestamps
    end
  end
end
