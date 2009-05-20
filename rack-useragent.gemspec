Gem::Specification.new do |s|
  s.name = "rack-useragent"
  s.version = "0.0.1"
  s.authors = ["Sergio Gil", "Luismi Cavallé"]
  s.email = "ballsbreaking@bebanjo.com"
  s.homepage = "http://github.com/bebanjo/rack-useragent"
  s.summary = "Rack Middleware for filtering by user agent"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc"]
  s.files = [
    "README.rdoc",
    "lib/rack/user_agent.rb",
    "lib/rack/user_agent/filter.rb"
  ]
  s.add_dependency('rack', '>= 0.9.1')
  s.add_dependency('josh-useragent', '>= 0')
end
