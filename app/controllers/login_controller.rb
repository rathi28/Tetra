class LoginController < ApplicationController

  # setup the C of the CRUD actions
  def create
    # check the users password and user existance.
    if user = User.authenticate(params[:username], params[:password])
      # adds the current user from this session
      session[:current_user_id] = user.id

      # log this event
      log_action('Login', current_user.username, current_user.id, 'User')

      # send user to dashboard
      redirect_to root_url
    else
      # respond with error and send user back to login with their last username loaded in username
      flash[:warning] = "Login Incorrect"
      flash[:username] = params[:username]
      redirect_to action: 'index' 
    end
  end

  # setup the D of the CRUD actions
  def destroy
    # log this event
    log_action('Logout', current_user.username, current_user.id, 'User')

    # removes the current user from this session
    @_current_user = session[:current_user_id] = nil

    # send user to dashboard
    redirect_to root_url
  end

  # controller action for default path to login page
  def index
    
  end
end