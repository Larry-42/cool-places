class ApplicationController < Sinatra::Base
  
  configure do
    set :views, Proc.new { File.join(root, "../views/")}
    enable :sessions
    set :session_secret, "the_color_of_infinity"
  end
  
  def logged_in?
    !!session[:user_id]
  end
  
  def current_user
    User.find(session[:user_id])
  end
  
  def place_is_valid?(parameters)
    place_valid = true
    #Validation:  Make sure that none of the fields are empty
    parameters.each do |k, v|
      if v.empty?
        place_valid = false
      end
    end
    
    #Validation:  Make sure that place is not named "deleted"
    if parameters[:name].downcase == "deleted"
      place_valid = false
    end
    
    #Validation:  Make sure that place does not exist
    if Place.find_by name: parameters[:name], location: parameters[:name]
      place_valid = false
    end
    
    place_valid
  end
  
  get '/' do
    #TODO:  Add redirect if already logged in
    erb :index
  end
  
  get '/signup' do
    #TODO:  Add redirect if already logged in
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
  
  get '/users/:id' do
    @user = User.find(params[:id])
    erb :'/users/show'
  end
  
  get '/places/:id/edit' do
    @place = Place.find(params[:id])
    if @place && logged_in? && @place.user_id == current_user.id
      erb :'/places/edit'
    else
      redirect to "/places/#{params[:id]}"
    end
  end
  
  get '/places/:id/delete' do
    @place = Place.find(params[:id])
    if @place && logged_in? && @place.user_id == current_user.id
      erb :'/places/delete'
    else
      redirect to "/places/#{params[:id]}"
    end
  end
  
  delete '/places/:id/delete' do
    @place = Place.find(params[:id])
    if !@place || !logged_in? || @place.user_id != current_user.id || params[:submit] == "No"
      redirect to "/places/#{params[:id]}"
    else
      @place.destroy
      redirect to "/places"
    end
  end
  
  patch '/places/:id/edit' do
    @place = Place.find(params[:id])
    if !@place || !logged_in? || @place.id != current_user.id
      redirect to '/places'
    end
    
    #validation--see if you're trying to set the place name and location to 
    #one that already exists!
    old_place_name = @place.name
    old_place_location = @place.location
    
    @place.name = nil
    @place.location = nil
    
    if place_is_valid?(params[:place])
      @place.update(params[:place])
    else
      @place.name = old_place_name
      @place.location = old_place_location
      redirect to "/places/#{params[:id]}/edit" 
    end
    redirect to "/places/#{params[:id]}" 
  end
  
  get '/places/:id' do
    @is_logged_in = logged_in?
    @place = Place.find(params[:id])
    erb :'/places/show'
  end
  
  post '/places/:id/comment' do
    if logged_in? && !params[:comment].empty? 
      Comment.create content: params[:comment], user_id: session[:user_id], place_id: params[:id]
      "Comment created"
    end
    redirect to "/places/#{params[:id]}"
  end
  
  get '/places' do
    @places = Place.all
    erb :'/places/places'
  end
  
  get '/createplace' do
    if !logged_in?
      redirect to '/'
    end
    
    erb :'/places/create'
  end
  
  post '/createplace' do
    if !logged_in?
      redirect to '/'
    end
    
    if !place_is_valid?(params[:place])
      redirect to '/createplace'
    end
    
    @new_place = current_user.places.build(params[:place])
    if @new_place.save
      #TODO:  Validate to place show page
      "Place successfully created"
    else
      redirect to '/createplace'
    end
  end
  
  get '/comments/:id/edit' do
    @comment = Comment.find(params[:id])
    if !@comment
      redirect to '/places'
    elsif !logged_in? || @comment.user_id != current_user.id
      redirect to "/places/#{@comment.place.id}"
    else
      erb :'/comments/edit'
    end
  end
  
  patch '/comments/:id/edit' do
  end
  
  get '/comments/:id/delete' do
    @comment = Comment.find(params[:id])
    if !@comment
      redirect to '/places'
    elsif !logged_in? || @comment.user_id != current_user.id
      redirect to "/places/#{@comment.place.id}"
    else
      erb :'/comments/delete'
    end
  end
  
  delete '/comments/:id/delete' do
  end

end
