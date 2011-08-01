require 'rubygems'
require 'rspec'
require "rspec/core/rake_task" # RSpec 2.0

# RSpec 2.0
RSpec::Core::RakeTask.new(:core) do |spec|
  #spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end

require 'code_stats'
CodeStats::Tasks.new

require 'rake/rdoctask'
desc "Generate documentation"
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'rdoc'
end

require 'bundler'
Bundler::GemHelper.install_tasks
