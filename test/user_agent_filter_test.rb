require 'test/unit'
require 'rubygems'
require 'mocha'

require File.dirname(__FILE__) + '/../lib/rack/user_agent'

class UserAgentFilterTest < Test::Unit::TestCase
  
  STATUS  = 0
  HEADERS = 1
  BODY    = 2
  
  def setup
    @app_response = stub
    @app = stub(:call => @app_response)
  end
  
  def teardown
    Object.send(:remove_const, "RAILS_ROOT") if defined?(RAILS_ROOT)
  end
  
  def test_user_agent_supported
    filter = Rack::UserAgent::Filter.new(@app, [{:browser => "Internet Explorer", :version => "7.0"}])
    env = {"HTTP_USER_AGENT" => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)"}
    @app.expects(:call).with(env).returns(@app_response)
    response = filter.call(env)
    assert_equal @app_response, response
  end
  
  def test_no_config_given
    filter = Rack::UserAgent::Filter.new(@app)
    env = {"HTTP_USER_AGENT" => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)"}
    response = filter.call(env)
    assert_equal @app_response, response
  end
  
  def test_no_user_agent
    filter = Rack::UserAgent::Filter.new(@app, [{:browser => "Internet Explorer", :version => "7.0"}])
    response = filter.call({})
    assert_equal @app_response, response
  end
  
  def test_user_agent_unsupported
    filter = Rack::UserAgent::Filter.new(@app, [{:browser => "Internet Explorer", :version => "7.0"}])
    response = filter.call("HTTP_USER_AGENT" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)")
    assert_equal 400, response[STATUS]
    assert response[BODY].include?("Sorry, your browser is not supported. Please upgrade")
  end
  
  def test_user_agent_not_unsupported
    filter = Rack::UserAgent::Filter.new(@app, [{:browser => "Internet Explorer", :version => "7.0"}])
    response = filter.call("HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14")
    assert_equal @app_response, response
  end
  
  def test_upgrade_html_is_served_if_available
    Object.const_set("RAILS_ROOT", File.dirname(__FILE__))
    filter = Rack::UserAgent::Filter.new(@app, [{:browser => "Internet Explorer", :version => "7.0"}])
    response = filter.call("HTTP_USER_AGENT" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)")
    assert_equal 400, response[STATUS]
    assert_equal "This is upgrade.html", response[BODY]
  end

  def test_localized_upgrade_html
    Object.const_set("RAILS_ROOT", File.dirname(__FILE__))
    filter = Rack::UserAgent::Filter.new(@app, [{:browser => "Internet Explorer", :version => "7.0"}])
    response = filter.call("HTTP_USER_AGENT" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)",
                           "rack.locale" => "es")
    assert_equal 400, response[STATUS]
    assert_equal "This is upgrade.es.html", response[BODY]
  end
  
  def test_erb_template
    filter = Rack::UserAgent::Filter.new(@app, [{:browser => "Internet Explorer", :version => "7.0"}], 
                                               :template => File.dirname(__FILE__) + "/upgrade.erb")
    response = filter.call("HTTP_USER_AGENT" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)")
    assert_equal 400, response[STATUS]
    assert_equal "Hello, Internet Explorer 6.0!", response[BODY]
  end
  
end