# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-useragent}
  s.version = "0.0.5"

  s.authors = ["Sergio Gil", "Luismi Cavall\303\251", "Paco Guzmán"]
  s.date = %q{2009-09-16}
  s.email = %q{ballsbreaking@bebanjo.com}
  s.homepage = %q{http://github.com/bebanjo/rack-useragent}
  s.summary = %q{Rack Middleware for filtering by user agent}
  s.license       = "MIT"
  s.files         = `git ls-files`.split($/)
  s.executables   = []
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'mocha', '0.9.8'

  s.add_dependency 'bundler', '>= 1.3'
  s.add_dependency 'rack', '>= 1.6.12'
  s.add_dependency 'useragent', '>= 0.4.16'
end
