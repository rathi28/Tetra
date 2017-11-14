class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

   private
 
  # Finds the User with the ID stored in the session with the key
  # :current_user_id This is a common way to handle user login in
  # a Rails application; logging in sets the session value and
  # logging out removes it.
  helper_method :current_user

  def current_user
      @current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
      #@current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
  end
  
  ##
  # Logs C(not R)UD Operations done by users
  def log_action(action, user, record, model)
    begin
      # Create a new ActionLog Object
      event = ActionLog.new()
      
      # Add the user to this object
      event.user = user
      
      # Add the action to this object
      event.action = action
      
      # Save the model type and its record ID(s) to this object
      event.target = model.to_s + ':' + record.to_s
      
      # Save the time of the event
      event.time_of_action = (Time.now.getutc - 7*60*60).to_s.gsub('UTC','PST')
      
      # Save this event to database
      event.save!

    rescue => e
      
    end
  end
  
  ##
  # Protect from non-admin access for dangerous operations (creating/editing/deleting)
  def admin_only()
    # if you are a logged in user
    # session[:current_user_id] = 123
    if(session[:current_user_id])
      # if you are an admin
      if(User.find(session[:current_user_id]).admin == 'yes')
        yield
      else
        # otherwise
        # send login failure and redirect to dashboard
        flash[:warning] = "Admin Login Required"
        redirect_to action: "index", controller: "dashboard"
      end
    else
      # otherwise
      # send login failure and redirect to login
      flash[:warning] = "Not Logged In"
      redirect_to "/login"
    end
  end

  ##
  # Protect from non-admin access for dangerous operations (creating/editing/deleting)
  def logged_in_only()
    # session[:current_user_id] = 123
    # if you are a logged in user
    if(session[:current_user_id])
      # execute script inside of this block
      yield
    else
      # otherwise
      # send login failure and redirect to login
      flash[:warning] = "Not Logged In"
      redirect_to "/login"
    end
  end

  # Catch a failed action, but don't propogate the problem to test level.
  # This version only displays a message
  def catch_simple
    begin
      yield
    rescue => e
      Rails.logger.info e.message
    end
  end

  ##
  # Record Error to the database (without recording test run)
  def log_error_to_database(e)
    error_obj = ErrorMessage.new()
    catch_simple do
      error_obj.class_name = e.class.to_s
    end
    catch_simple do
      error_obj.message = e.message
    end
    catch_simple do
      error_obj.backtrace = e.backtrace.join("\n")
    end
    error_obj.save!
  end

end
