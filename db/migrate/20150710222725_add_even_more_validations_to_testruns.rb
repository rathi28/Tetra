class AddEvenMoreValidationsToTestruns < ActiveRecord::Migration
  def change
    add_column :testruns, :Standard, :string
    add_column :testruns, :Rush, :string
    add_column :testruns, :Overnight, :string
    add_column :testruns, :continuitysh, :string
    add_column :testruns, :sas_kit_name, :string
    add_column :testruns, :cart_quanity, :string
    add_column :testruns, :vitamin_title, :string
    add_column :testruns, :vitamin_description, :string
    add_column :testruns, :conf_kit_name, :string
    add_column :testruns, :conf_vitamin_name, :string
    add_column :testruns, :confvitaminpricing, :string
    add_column :testruns, :confpricing, :string
    add_column :testruns, :shipping_conf, :string
  end
end
