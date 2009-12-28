require "rubygems"
require "treetop"

#require "coffee/runtime"
require "coffee/generator"
require "coffee/nodes"

if File.file?(File.dirname(__FILE__) + "/coffee/grammar.rb")
  # Take compiled one
  require "coffee/grammar"
else
  Treetop.load File.dirname(__FILE__) + "/coffee/grammar.tt"
end

module Coffee
  class ParserError < RuntimeError; end

  # Compiles the given source code to its LLVM-IR representation.
  #
  # @param [String] code
  #   source code to parse and compile
  # @return [Coffee::Generator]
  #   the LLVM-IR generator for the resulting program
  # @raise [ParserError]
  #   the source code is syntactically invalid
  def self.compile(code)
    generator = Coffee::Generator.new
    parser    = CoffeeParser.new

    node = parser.parse(code)

    if node
      node.codegen(generator)
    else
      raise ParserError, parser.failure_reason
    end

    generator
  end

end
