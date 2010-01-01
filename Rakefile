require 'rake'
require 'rake/testtask'
require 'yard'

task :default => [:generate_parser, :test]

desc "Run unit tests"
Rake::TestTask.new("test") { |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = false
}

desc "Generate parser"
task :generate_parser do
  sh "tt lib/coffee/grammar.tt"
end

desc "Measure test coverage"
task :coverage do
    sh "rcov -x $HOME/.gem test/*_test.rb"
end

desc "Generate documentation"
YARD::Rake::YardocTask.new("doc") do |t|
  t.files   = ['lib/coffee/generator.rb', 'lib/coffee/nodes.rb',
               'lib/coffee.rb', 'README.md']
  t.options = ['--hide-void-return', '-', 'LICENSE']
end
