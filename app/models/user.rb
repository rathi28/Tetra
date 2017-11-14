class User < ActiveRecord::Base
  # maps to User table in database
  include Adauth::Rails::ModelBridge

  AdauthMappings = {
    :login => :login,
    :group_strings => :cn_groups,
    :ou_strings => :dn_ous,
    :name => :name
  }

  AdauthSearchField = [:login, :login]

  def groups
    group_strings.split(", ")
  end

  # # authenticate a user and return user object to controller if correct authentication
  # def self.authenticate(user, pass)
  # 	begin
  # 		target = self.find_by(username: user)
  # 		raise "Login Failed" if(target == nil)
  # 	rescue => e
  # 		return nil
  # 	end
  # 	if(target.password == pass)
  # 		return target
  # 	else
  # 		return nil
  # 	end
  #end
end