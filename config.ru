# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run JoruriGw::Application

if defined?(PhusionPassenger)
  PhusionPassenger.require_passenger_lib 'rack/out_of_band_gc'
  use PhusionPassenger::Rack::OutOfBandGc, 5
end
