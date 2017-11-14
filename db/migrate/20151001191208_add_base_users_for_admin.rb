class AddBaseUsersForAdmin < ActiveRecord::Migration
  def up
    Admin.create login: 'cmoseley'

    Admin.create login: 'ssankara'
  end

  def down
    Admin.all.destroy_all
  end
end
