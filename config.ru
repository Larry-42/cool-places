require './config/environment.rb'

use Rack::MethodOverride

use UsersController
use PlacesController
use CommentsController
run ApplicationController
