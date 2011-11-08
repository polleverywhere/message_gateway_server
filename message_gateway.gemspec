# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'message_gateway/version'

Gem::Specification.new do |s|
  s.name        = "message_gateway"
  s.version     = MessageGateway::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Hull", "Ryan Wilcox", "Sean Eby", "Brad Gessler", "Jeff Vyduna"]
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/message_gateway"
  s.description = "A bidirectional short message gateway."
  s.summary     = "A bidirectional short message gateway."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "tumbler"

  s.add_dependency "activerecord", '~> 3.0.9'
  s.add_dependency 'yajl-ruby', ">= 0.7.5"
  s.add_dependency 'oauth', ">= 0.4.2"
  s.add_dependency "json"
  s.add_dependency "mysqlplus"
  s.add_dependency "thin", "~> 1.2.11"
  s.add_dependency "will_paginate", "~> 3.0pre"
  s.add_dependency "haml"
  s.add_dependency "padrino", "~> 0.10.0"
  s.add_dependency "sinatra", "~> 1.2.6"

  s.add_dependency "rack", '~> 1.1'
  s.add_dependency "chirpstream"
  s.add_dependency "nokogiri"
  s.add_dependency "em-http-request", "~> 1.0.0.beta.4"
  s.add_dependency "thin_async", '>= 0.1.1'
  s.add_dependency "http_router", '>= 0.8.10'
  s.add_dependency "em-jack"
  s.add_dependency "eventmachine"

  s.add_development_dependency "bundler", "~> 1.0.15"
  s.add_development_dependency "freegenie-em-spec" #freegenie's fork includes support for Rspec 2
  s.add_development_dependency "rake"
  s.add_development_dependency "mocha"
  s.add_development_dependency "rspec"
  s.add_development_dependency "dirge"
  s.add_development_dependency "code_stats"
  s.add_development_dependency "ruby-debug19"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.require_path = 'lib'
end

