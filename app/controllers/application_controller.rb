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
    session[:user_id] ? User.find(session[:user_id]) : nil
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
    if logged_in?
      redirect to '/places'
    end
    erb :index
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
    @user = current_user
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
    @user = current_user
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
      redirect to "/places/#{@new_place.id}"
    else
      redirect to '/createplace'
    end
  end
  
  get '/comments/:id/edit' do
    @comment = Comment.find(params[:id])
    if !@comment
      redirect to '/places'
    elsif !logged_in? || @comment.user_id != current_user.id
      if @comment.place
        redirect to "/places/#{@comment.place.id}"
      else
        redirect to "/places"
      end
    else
      erb :'/comments/edit'
    end
  end
  
  patch '/comments/:id/edit' do
    @comment = Comment.find(params[:id])
    if !@comment
      redirect to "/places"
    elsif logged_in? && @comment.user_id == current_user.id
      @comment.update(params[:comment])
    end
    
    if @comment.place
      redirect to "/places/#{@comment.place.id}"
    else
      redirect to "/places"
    end
  end
  
  get '/comments/:id/delete' do
    @comment = Comment.find(params[:id])
    if !@comment
      redirect to '/places'
    elsif !logged_in? || @comment.user_id != current_user.id
      if @comment.place
        redirect to "/places/#{@comment.place.id}"
      else
        redirect to "/places"
      end
    else
      erb :'/comments/delete'
    end
  end
  
  delete '/comments/:id/delete' do
    @comment = Comment.find(params[:id])
    if !@comment
      redirect to "/places"
    elsif !logged_in? || @comment.user_id != current_user.id || params[:submit] == "No"
      if @comment.place
        redirect to "/places/#{@comment.place.id}"
      else
        redirect to "/places"
      end
    else
      place_id = @comment.place ? @comment.place.id : nil
      @comment.destroy
      if place_id
        redirect to "/places/#{place_id}"
      else
        redirect to "/places"
      end
    end
  end

end
