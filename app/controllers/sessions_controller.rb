class SessionsController < ApplicationController
	include Adauth::Rails::Helpers
	def new
		redirect_to root_path if current_user
	end

	def create
		if(params[:username].empty? || params[:password].empty?)
			flash[:required] = {}
			flash[:required][:username] = true if params[:username].empty?
			flash[:required][:password] = true if params[:password].empty?
			flash[:username] = params[:username]
			@username = params[:username]
			redirect_to '/login'
			return
		end
		admin = Admin.all()
		ldap_user = Adauth.authenticate(params[:username], params[:password])

		if ldap_user

			

        	user = User.return_and_create_from_adauth(ldap_user)

        	user.username = user.login
        	session[:current_user_id] = user.id
        	if (Admin.where(:login => user.login).empty? == false)
        		user.admin = 'yes'
        	else
        		user.admin = 'no'
        	end
        	# user.email = ldap_user.email
        	user.save!

        	# log this event
      		log_action('Login', current_user.username, current_user.id, 'User')
        	
        	redirect_to root_path
    	else
    		flash[:username] = params[:username]
        	redirect_to({action: 'new'}, notice: "Invalid Login")
    	end
	end

	def destroy
		# log this event
    	log_action('Logout', current_user.username, current_user.id, 'User')
		
		session[:current_user_id] = nil
		redirect_to root_path
	end
end