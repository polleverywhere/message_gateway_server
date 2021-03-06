require 'rubygems'

# RSpec 2.0
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |spec|
  #spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end

# Code stats
require 'code_stats'
CodeStats::Tasks.new

# RDocs
require 'rdoc/task'
desc "Generate documentation"
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'rdoc'
end

# Bundler gem tasks
require 'bundler'
Bundler::GemHelper.install_tasks

# Custom tasks... we problaby don't need these.
desc "Prints out the list of carriers that have add_carrier_mapping directives but no corresponding registered carrier"
task :find_orphaned_mappings do
	require './lib/message_gateway/phone_number'
	require './lib/message_gateway/util/carrier'

  Dir.glob("lib/message_gateway/parser/*.rb") do |ruby_file|
    File.open(ruby_file) do |f|
    	f.each do |line|
    		if line =~ /add_carrier_mapping\W+?:(.+?),/
    			carrier_declaration = $+
    			#puts ruby_file, carrier_declaration
					unless MessageGateway::Util::Carrier::CarrierInfo.lookup carrier_declaration
						puts "**WARNING: FILE #{ruby_file} declares orphan carrier mapping #{carrier_declaration}"
					end
    		end
    	end
    end
  end
end

desc "Prints the known carrier codes - their symbol and their name"
task :print_known_carriers do
	require './lib/message_gateway/phone_number'
	require './lib/message_gateway/util/carrier'

  MessageGateway::Util::Carrier::CarrierInfo.carrier_mapping.each_pair do |key, value|
    puts "#{key}\t#{value.name}"
  end
end
