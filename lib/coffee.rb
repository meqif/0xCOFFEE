require "rubygems"
require "treetop"

#require "coffee/runtime"
#require "coffee/generator"
#require "coffee/nodes"

if File.file?(File.dirname(__FILE__) + "/coffee/grammar.rb")
  # Take compiled one
  require "coffee/grammar"
else
  Treetop.load File.dirname(__FILE__) + "/coffee/grammar.tt"
end

module Coffee
  class ParserError < RuntimeError; end

  def self.compile(code)
    #generator = Coffee::Generator.new
    parser    = CoffeeParser.new

    if node = parser.parse(code)
    #  node.compile(generator)
    else
      raise ParserError, parser.failure_reason
    end

    #generator
  end
end
