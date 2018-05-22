class PlacesController < ApplicationController
  
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

end
