require 'rubygems'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

YARD::Rake::YardocTask.new
RSpec::Core::RakeTask.new

task :test => :spec
task :default => :test
