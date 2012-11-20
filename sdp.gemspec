$:.push File.expand_path("../lib", __FILE__)
require 'sdp/version'

Gem::Specification.new do |s|
  s.name = %q{sdp}
  s.version = SDP::VERSION
  s.author = "Steve Loveless"

  s.description = %q{This gem allows for parsing SDP (Session Description
Protocol) information in to a Ruby object, making it easy to read
and work with that data.  It also allows for easily creating SDP objects
that can be converted to text using}

  s.email = %{steve.loveless@gmail.com}
  s.extra_rdoc_files = Dir.glob("*.rdoc")
  s.files = Dir.glob("{lib,spec}/**/*") + Dir.glob("*.rdoc") +
    %w(.gemtest .rspec .yardopts Gemfile Rakefile sdp.gemspec)
  s.homepage = %{http://github.com/turboladen/sdp}
  s.licenses = %w(MIT)
  s.rubygems_version = %q{1.5.2}
  s.summary = %{Parse and create SDP (Session Description Protocol) text based on RFC4566.}
  s.test_files = Dir.glob("spec/**/*")

  s.add_runtime_dependency 'parslet', ">= 1.1.0"

  s.add_development_dependency 'bundler', "> 1.0.0"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', ">= 2.6.0"
  s.add_development_dependency 'simplecov', ">= 0.5.0"
  s.add_development_dependency 'yard', ">= 0.6.0"
end
