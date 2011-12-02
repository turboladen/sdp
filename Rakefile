require 'rubygems'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'code_statistics'

# RSpec & `gem test`
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = "-w"
  t.rspec_opts = ['--format', 'documentation', '--color']
end
task :test => :spec

# Yard
YARD::Rake::YardocTask.new

# code_statistics
STATS_DIRECTORIES = [
  %w(Library            lib/),
  %w(Behavior\ tests    features/),
  %w(Unit\ tests        spec/)
].collect { |name, dir| [ name, "#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end
