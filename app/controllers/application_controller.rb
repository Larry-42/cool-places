class ApplicationController < Sinatra::Base
  
  configure do
    set :views, Proc.new { File.join(root, "../views/")}
    enable :sessions
    set :session_secret, "the_color_of_infinity"
  end
  
  helpers do
    def logged_in?
      !!session[:user_id]
    end
    
    def current_user
      session[:user_id] ? User.find(session[:user_id]) : nil
    end
  end

end
