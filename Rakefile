require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Run all tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rack-useragent"
    gemspec.authors = ["Sergio Gil", "Luismi Cavallé"]
    gemspec.email = "ballsbreaking@bebanjo.com"
    gemspec.homepage = "http://github.com/bebanjo/rack-useragent"
    gemspec.summary = "Rack Middleware for filtering by user agent"
    gemspec.add_dependency('rack', '>= 0.9.1')
    gemspec.add_dependency('josh-useragent', '= 0.0.2')
  end
rescue LoadError
end
