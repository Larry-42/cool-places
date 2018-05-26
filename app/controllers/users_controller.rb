class UsersController < ApplicationController
  
  get '/' do
    #Old index page was irrelevant after adding navbar
    redirect to '/places'
  end
  
  get '/signup' do
    if logged_in?
      redirect to '/places'
    end
    erb :signup
  end
  
  post '/signup' do
    #Validation--Make sure that no parameters are empty
    params[:user].each do |k, v|
      if v.empty?
        redirect to '/signup'
      end
    end
    
    #Validation--Make sure that password is at least 5 characters long
    if params[:user][:password].length < 5
      redirect to '/signup'
    end
    
    #Validation--Make sure that passwords match
    if params[:user][:password] != params[:confirm]
      redirect to '/signup'
    end
    
    #Validation--Make sure that username is not already taken
    if User.find_by username: params[:user][:username]
      redirect to '/signup'
    end
  
    session[:user_id] = User.create(params[:user]).id
    redirect to '/places'
  end
  
  get '/login' do
    if logged_in?
      redirect to '/places'
    else
      erb :login
    end
  end
  
  post '/login' do
    if logged_in?
      redirect to "/places"
    end
    user_login = User.find_by username: params[:username]
    if user_login && user_login.authenticate(params[:password])
      session[:user_id] = user_login.id
      redirect to '/places'
    else
      redirect to '/login'
    end
  end
  
  get '/logout' do
    session.clear
    redirect to '/'
  end
  
  get '/changepassword' do
    if logged_in?
      erb :'/users/change_password'
    else
      redirect to "/"
    end
  end
  
  post '/changepassword' do
    if logged_in?
      if current_user.authenticate(params[:old_password]) && params[:user][:password] == params[:confirm_password] && params[:user][:password].length >= 5
        current_user.update(params[:user])
        redirect to "/places"
      else
        redirect to '/changepassword'
      end
    else
      redirect to "/"
    end
  end
  
  get '/users/:id' do
    @curr_user = current_user
    @user = User.find(params[:id])
    erb :'/users/show'
  end
end
