class UsersController < ApplicationController
  
  get '/' do
    #Old index page was irrelevant after adding navbar
    redirect to '/places'
  end
  
  get '/signup' do
    if logged_in?
      flash[:message] = '<p class="text-warning">You are already logged in.  You must log out if you wish to login under a different username.</p>'
      redirect to '/places'
    end
    erb :signup
  end
  
  post '/signup' do
    #Validation--Make sure that no parameters are empty
    params[:user].each do |k, v|
      if v.empty?
        flash[:message]= '<p class="text-warning">You cannot have blank fields in the form below.</p>'
        redirect to '/signup'
      end
    end
    
    #Validation--Make sure that password is at least 5 characters long
    if params[:user][:password].length < 5
      flash[:message] = '<p class="text-warning">Your password must be at least five characters long.</p>'
      redirect to '/signup'
    end
    
    #Validation--Make sure that passwords match
    if params[:user][:password] != params[:confirm]
      flash[:message] = '<p class="text-warning">Passwords must match to signup</p>'
      redirect to '/signup'
    end
    
    #Validation--Make sure that username is not already taken
    if User.find_by username: params[:user][:username]
      flash[:message] = '<p class="text-warning">The username you entered is already taken, please select a different username.</p>'
      redirect to '/signup'
    end
    flash[:message] = '<p class = "text-success">Successfully signed up.</p>'
    session[:user_id] = User.create(params[:user]).id
    redirect to '/places'
  end
  
  get '/login' do
    if logged_in?
      flash[:message] = '<p class="text-warning">You are already logged in.  You must log out if you wish to login under a different username.</p>'
      redirect to '/places'
    else
      erb :login
    end
  end
  
  post '/login' do
    if logged_in?
      flash[:message] = '<p class="text-warning">You are already logged in.  You must log out if you wish to login under a different username.</p>'
      redirect to "/places"
    end
    user_login = User.find_by username: params[:username]
    if user_login && user_login.authenticate(params[:password])
      session[:user_id] = user_login.id
      flash[:message] = '<p class="text-success">Successfully logged in.</p>'
      redirect to '/places'
    else
      flash[:message] = '<p class="text-warning">Wrong password or invalid user.</p>'
      redirect to '/login'
    end
  end
  
  get '/logout' do
    session.clear
    flash[:message] = '<p class="text-success">You are logged out.</p>'
    redirect to '/places'
  end
  
  get '/changepassword' do
    if logged_in?
      erb :'/users/change_password'
    else
      flash[:message] = '<p class="text-warning">You can only change your password if logged in.</p>'
      redirect to "/places"
    end
  end
  
  post '/changepassword' do
    if logged_in?
      if current_user.authenticate(params[:old_password]) && params[:user][:password] == params[:confirm_password] && params[:user][:password].length >= 5
        current_user.update(params[:user])
        flash[:message]='<p class="text-success">Successfully changed password.</p>'
        redirect to "/places"
      else
        flash[:message]='<p class="text-warning">Error changing password.  You must enter your old password to authenticate, your new password must be more than five characters, and you must re-enter your password to change your password.</p>'
        redirect to '/changepassword'
      end
    else
      flash[:message] = '<p class="text-warning">You can only change your password if logged in.</p>'
      redirect to "/places"
    end
  end
  
  get '/users/:id' do
    @curr_user = current_user
    @user = User.find(params[:id])
    erb :'/users/show'
  end
end
