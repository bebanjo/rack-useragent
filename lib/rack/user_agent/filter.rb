require 'rubygems'
require 'user_agent'
require 'erb'
require 'ostruct'

module Rack::UserAgent
  class Filter
    def initialize(app, config = [], options = {})
      @app = app
      @browsers = config
      @template = options[:template]
    end

    def call(env)
      browser = UserAgent.parse(env["HTTP_USER_AGENT"]) if env["HTTP_USER_AGENT"]
      if unsupported?(browser)
        [400, {"Content-Type" => "text/html"}, page(env['rack.locale'], browser)]
      else
        @app.call(env)
      end
    end

    private

    def unsupported?(browser)
       browser && browser.version && @browsers.any? { |hash| browser < OpenStruct.new(hash) }
    end

    def page(locale, browser)
      return "Sorry, your browser is not supported. Please upgrade" unless template = template_file(locale)
      @browser = browser # for the template
      ERB.new(File.read(template)).result(binding)
    end

    def template_file(locale)
      candidates = [ @template ]
      
      if defined?(RAILS_ROOT)
        candidates += [ File.join(RAILS_ROOT, "public", "upgrade.#{locale}.html"),
                        File.join(RAILS_ROOT, "public", "upgrade.html") ] 
      end
               
      candidates.compact.detect{ |template| File.exists?(template) }
    end
  end
end
