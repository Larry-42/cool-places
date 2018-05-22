class CommentsController < ApplicationController

  #NOTE:  Because the route is /places/:id/comment, the code to create
  #a comment is in comments_controller.rb
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
