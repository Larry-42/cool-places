class ApplicationController < Sinatra::Base
  
  configure do
    set :views, Proc.new { File.join(root, "../views/")}
    enable :sessions
    set :session_secret, "the_color_of_infinity"
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
    binding.pry
    #TODO:  Add validation
    "Logged in"
  end

end
