require './config/environment.rb'

use Rack::MethodOverride

use UsersController
use CommentsController
use PlacesController
run ApplicationController
