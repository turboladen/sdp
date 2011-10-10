require 'rubygems'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = "-w"
  t.rspec_opts = ['--format', 'documentation', '--color']
end
task :test => :spec

YARD::Rake::YardocTask.new

# Load all extra rake tasks
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].each { |ext| load ext }
