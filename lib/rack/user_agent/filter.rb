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
      if unsupported?(env["HTTP_USER_AGENT"])
        @browser = UserAgent.parse(env["HTTP_USER_AGENT"])
        # [200, {"Content-Type" => "text/html"}, [page(env['rack.locale'])]]
        [400, {"Content-Type" => "text/html"}, page(env['rack.locale'])]
      else
        @app.call(env)
      end
    end

    private

    def unsupported?(user_agent)
      user_agent && @browsers.any? { |browser| UserAgent.parse(user_agent) < OpenStruct.new(browser) }
    end

    def page(locale)
      template_file = template_file(locale)
      return "Sorry, your browser is not supported. Please upgrade" unless template_file
      template = ERB.new(File.read(template_file))
      template.result(binding)
    end

    def template_file(locale)
      candidates = [ @template ]
      candidates += [ File.join(RAILS_ROOT, "public", "upgrade.#{locale}.html"),
                      File.join(RAILS_ROOT, "public", "upgrade.html") ] if defined?(RAILS_ROOT)
               
      candidates.compact.detect{ |template| File.exists?(template) }
    end
  end
end