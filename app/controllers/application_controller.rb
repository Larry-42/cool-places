class ApplicationController < Sinatra::Base
  
  set :views, Proc.new { File.join(root, "../views/")}
  
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
  
    User.create(params[:user])
    
    #TODO: Set session, redirect to show places
    "Successfully signed up"
  end

end
