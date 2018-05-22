require './config/environment.rb'

use Rack::MethodOverride

use PlacesController
run ApplicationController
