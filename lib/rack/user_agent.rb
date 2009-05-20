require 'rack'

module Rack::UserAgent
  VERSION = "0.1.0"
  autoload :Filter, 'rack/user_agent/filter'  
end