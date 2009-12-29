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
  # @param [Bool] test
  #   whether to enable testing options or not
  # @return [Coffee::Generator]
  #   the LLVM-IR generator for the resulting program
  # @raise [ParserError]
  #   the source code is syntactically invalid
  def self.compile(code, test=false)
    generator = Coffee::Generator.new
    parser    = CoffeeParser.new

    node = parser.parse(code)

    if node
      if not test
        node.codegen(generator)
      else
        node.codegen_test(generator)
      end
    else
      raise ParserError, parser.failure_reason
    end

    generator
  end

end
