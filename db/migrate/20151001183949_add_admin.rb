class AddAdmin < ActiveRecord::Migration
  def change
  	create_table :admins do |t|
  		t.string :login
  	end
  end
end
