class ApplicationController < Sinatra::Base
  
  configure do
    set :views, Proc.new { File.join(root, "../views/")}
    enable :sessions
    set :session_secret, "the_color_of_infinity"
  end
  
  def logged_in?
    !!session[:user_id]
  end
  
  get '/' do
    "Welcome to cool places!"
  end
  
  get '/signup' do
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
    
    #Validation--Make sure that username is not already taken
    if User.find_by username: params[:user][:username]
      redirect to '/signup'
    end
  
    session[:user_id] = User.create(params[:user]).id
    
    #TODO: redirect to show places
    "Successfully signed up"
  end
  
  get '/login' do
    #TODO:  Redirect if already logged in
    erb :login
  end
  
  post '/login' do
    #TODO:  Redirect once logged in, validate if logged in
    user_login = User.find_by username: params[:username]
    if user_login && user_login.authenticate(params[:password])
      session[:user_id] = user_login.id
      "Logged in"
    else
      "Failed to validate"
    end
  end
  
  get '/logout' do
    #TODO:  Add redirect, validate if logged in
    session.clear
    "Successfully logged out"
  end
  
  get '/createplace' do
    #TODO:  Change redirect location
    if !logged_in?
      redirect to '/login'
    end
    
    erb :'/places/create'
  end
  
  post '/createplace' do
    #TODO:  Add place creation, validation functionality
  end

end
