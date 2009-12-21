require 'rake'
require 'rake/testtask'

task :default => :generate_parser

desc "Run unit tests"
Rake::TestTask.new("test") { |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = false
}

desc "Generate parser"
task :generate_parser do
  sh "tt lib/coffee/grammar.tt"
end
