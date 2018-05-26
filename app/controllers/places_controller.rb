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
      flash[:message] = '<p class="text-warning">You can only edit a place that you created, when logged in under the account you used to create it.</p>'
      redirect to "/places/#{params[:id]}"
    end
  end
  
  get '/places/:id/delete' do
    @place = Place.find(params[:id])
    if @place && logged_in? && @place.user_id == current_user.id
      erb :'/places/delete'
    else
      flash[:message] = '<p class="text-warning">You can only delete a place that you created, when logged in under the account you used to create it.</p>'
      redirect to "/places/#{params[:id]}"
    end
  end
  
  delete '/places/:id/delete' do
    @place = Place.find(params[:id])
    if !@place || !logged_in? || @place.user_id != current_user.id || params[:submit] == "No"
      flash[:message] = '<p class="text-warning">You can only delete a place that you created, when logged in under the account you used to create it.</p>'
      redirect to "/places/#{params[:id]}"
    else
      @place.destroy
      flash[:message] = '<p class="text-success">Successfully deleted your place.</p>'
      redirect to "/places"
    end
  end
  
  patch '/places/:id/edit' do
    @place = Place.find(params[:id])
    if !@place || !logged_in? || @place.user_id != current_user.id
      flash[:message] = '<p class="text-warning">You can only edit a place that you created, when logged in under the account you used to create it.</p>'
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
      flash[:message] = '<p class="text-success">Successfully updated your place.</p>'
    else
      @place.name = old_place_name
      @place.location = old_place_location
      flash[:message] = '<p class="text-warning">Place is invalid.  You cannot have blank fields, duplicate an existing place, or name a place "Deleted"</p>'
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
  
  get '/places' do
    @places = Place.all
    @user = current_user
    erb :'/places/places'
  end
  
  #Just because I have issues when moving around manually...
  get '/places/' do
    redirect to '/places'
  end
  
  get '/createplace' do
    if !logged_in?
      flash[:message] = '<p class="text-warning">You need to be logged in to share a new place.</p>'
      redirect to '/places'
    end
    
    erb :'/places/create'
  end
  
  post '/createplace' do
    if !logged_in?
      flash[:message] = '<p class="text-warning">You need to be logged in to share a new place.</p>'
      redirect to '/places'
    end
    
    if !place_is_valid?(params[:place])
      flash[:message] = '<p class="text-warning">Place is invalid.  You cannot have blank fields, duplicate an existing place, or name a place "Deleted"</p>'
      redirect to '/createplace'
    end
    
    @new_place = current_user.places.build(params[:place])
    if @new_place.save
      flash[:message] = '<p class="text-success">Successfully shared your new place.</p>'
      redirect to "/places/#{@new_place.id}"
    else
      redirect to '/createplace'
    end
  end

end
