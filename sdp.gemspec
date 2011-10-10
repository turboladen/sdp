$:.push File.expand_path("../lib", __FILE__)
require 'sdp/version'

Gem::Specification.new do |s|
  s.name = %q{sdp}
  s.version = SDP::VERSION

  s.authors = ["Steve Loveless"]
  s.description = %q{This gem allows for parsing SDP (Session Description
    Protocol) information in to a Ruby object, making it easy to read 
    and work with that data.  It also allows for easily creating SDP objects 
    that can be converted to text using}
  s.email = %q{steve.loveless@gmail.com}
  s.extra_rdoc_files = Dir.glob("*.rdoc")
  s.files = Dir.glob("{features,lib,spec,tasks/**/*") + Dir.glob("*.rdoc") +
    %w(.gemtest .rspec .yardopts Gemfile Rakefile sdp.gemspec)
  s.homepage = %q{http://github.com/turboladen/sdp}
  s.licenses = %w(MIT)
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{Parse and create SDP (Session Description Protocol) text based on RFC4566.}
  s.test_files = Dir.glob("spec/**/*")

  s.add_runtime_dependency(%q<parslet>, ["~> 1.1.0"])

  s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
  s.add_development_dependency(%q<rspec>, [">= 2.6.0"])
  s.add_development_dependency(%q<yard>, [">= 0.6.0"])
end
