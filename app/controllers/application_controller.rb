class ApplicationController < Sinatra::Base
  
  set :views, Proc.new { File.join(root, "../views/")}
  
  get '/' do
    "Welcome to cool places!"
  end
  
  get '/signup' do
    erb :signup
  end
  
  post '/signup' do
    #TODO:  Add signup
  end

end
