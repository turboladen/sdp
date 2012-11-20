require 'rubygems'
require 'bundler/gem_tasks'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'yard'


Cucumber::Rake::Task.new
RSpec::Core::RakeTask.new

task :test => [:spec, :cucumber]
task :default => :test

YARD::Rake::YardocTask.new
