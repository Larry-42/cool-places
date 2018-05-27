class CommentsController < ApplicationController

  post '/places/:id/comment' do
    if logged_in? && !params[:comment].empty? 
      Comment.create content: params[:comment], user_id: session[:user_id], place_id: params[:id]
      flash[:message] = '<p class="text-success">Successfully added your comment.</p>'
    else
      flash[:message] = '<p class="text-warning">You must be logged in to comment, and the comment content cannot be blank.</p>'
    end
    redirect to "/places/#{params[:id]}"
  end
  
  get '/comments/:id/edit' do
    @comment = Comment.find(params[:id])
    if !@comment
      flash[:message] = '<p class="text-warning">Comment not found.</p>'
      redirect to '/places'
    elsif !logged_in? || @comment.user_id != current_user.id
      flash[:message] = '<p class="text-warning">You can only edit a comment that you made when logged in using the same username you used to create the comment.</p>'
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
      flash[:message] = '<p class="text-warning">Comment not found.</p>'
      redirect to "/places"
    elsif logged_in? && @comment.user_id == current_user.id && !params[:comment][:content].empty?
      flash[:message] = '<p class = "text-success">Successfully updated your comment.</p>'
      @comment.update(params[:comment])
    else
      flash[:message] = '<p class="text-warning">You can only edit a comment that you made when logged in using the same username you used to create the comment.  Comment cannot be made blank.</p>'
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
      flash[:message] = '<p class="text-warning">Comment not found.</p>'
      redirect to '/places'
    elsif !logged_in? || @comment.user_id != current_user.id
      flash[:message] = '<p class="text-warning">You can only delete a comment that you made when logged in using the same username you used to create the comment.</p>'
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
      flash[:message] = '<p class="text-warning">Comment not found.</p>'
      redirect to "/places"
    elsif !logged_in? || @comment.user_id != current_user.id || params[:submit] == "No"
      flash[:message] = '<p class="text-info">Comment was not deleted.  As a reminder, uou can only delete a comment that you made when logged in using the same username you used to create the comment.</p>'
      if @comment.place
        redirect to "/places/#{@comment.place.id}"
      else
        redirect to "/places"
      end
    else
      place_id = @comment.place ? @comment.place.id : nil
      @comment.destroy
      flash[:message] = '<p class="text-success">You have successfully deleted your comment.</p>'
      if place_id
        redirect to "/places/#{place_id}"
      else
        redirect to "/places"
      end
    end
  end
  
end
