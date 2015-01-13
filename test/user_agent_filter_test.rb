require 'test/unit'
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

  def test_user_agent_supported_when_not_provide_version
    ["Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/534.34 (KHTML, like Gecko) Qt/4.8.4 Safari/534.34",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/534.57.7 (KHTML, like Gecko)",
    "Mozilla/5.0 (Unknown; Linux x86_64) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) QuickLook/5.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.77.4 (KHTML, like Gecko) QuickLook/5.0"].each do |user_agent|
      assert_equal UserAgent.parse(user_agent).version, nil

      filter = Rack::UserAgent::Filter.new(@app, [{:browser => "Safari", :version => "3.0"},
                                                  {:browser => "Internet Explorer", :version => "7.0"}])
      env    = {"HTTP_USER_AGENT" => user_agent}
      @app.expects(:call).with(env).returns(@app_response)
      response = filter.call(env)
      assert_equal @app_response, response
    end
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
