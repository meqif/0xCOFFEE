module Coffee
  class ::Treetop::Runtime::SyntaxNode
    def value
      text_value
    end

    def codegen(context)
    end
  end

  # @abstract A +Node+ represents a generic node of the AST.
  class Node < Treetop::Runtime::SyntaxNode
    # Value of the node
    #
    # @return [Object]
    #   the value of the node
    def value; end

    # Generates the code equivalent to this node. May go down the AST.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [Object, nil]
    #   the result of the code generation, if any
    def codegen(context); end
  end

  # Represents the root node of the AST.
  class Code < Node
    # Generates the code equivalent to this node. May go down the AST.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [LLVM::ReturnInst]
    #   the result of the code generation
    def codegen(context)
      context.preamble
      value.each {|statement| statement.codegen(context) }
      context.return(0.llvm)
    end

    # Generates the code equivalent to this node, with the main function
    # returning the value of the expression. May go down the AST.
    # +For testing purposes (i.e.: unit tests) only!+
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [LLVM::ReturnInst]
    #   the result of the code generation
    def codegen_test(context)
      context.preamble
      ret = nil
      value.each {|statement| ret = statement.codegen(context) }
      context.return(ret)
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "Code(#{value.join(',')})"
    end
  end

  # Represents a print node in the AST.
  class Print < Node
    # Value of the node
    #
    # @return [Object]
    #   the value of the node
    def value
      expression
    end

    # Generates the code equivalent to this node. May go down the AST.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [Object, nil]
    #   the result of the code generation, if any
    def codegen(context)
      str = context.new_string("%d\n")
      context.call("printf", str, value.codegen(context))
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "Print(#{value})"
    end
  end

  # Represents an Expression node in the AST.
  class Expression < Node
    # Generates the code equivalent to this node. May go down the AST.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [Object, nil]
    #   the result of the code generation, if any
    def codegen(context)
      value.codegen(context)
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "#{value}"
    end
  end

  # Represents a Binary Operation (such as Addition, Subtraction,
  # Multiplication, Division and Modulo) in the AST.
  class BinOp < Node
    OP_NAME = { :+ => "Addition", :- => "Subtraction", :* => "Multiplication",
                :/ => "Division", :% => "Modulo" }

    # @return [Symbol]
    #   the symbol representation of the operator
    def operator
      op.value.to_sym
    end

    # Generates the code equivalent to this node. May go down the AST.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [LLVM::BinaryOperator]
    #   the result of the code generation
    def codegen(context)
      context.bin_op(operator, left.codegen(context), right.codegen(context))
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "#{OP_NAME[operator]}(#{left},#{right})"
    end
  end

  # Represents an assignment in the AST.
  class Assign < Node
    # Value of the node
    #
    # @return [Object]
    #   the value of the node
    def value
      expression
    end

    # Generates the code equivalent to this node. May go down the AST.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [LLVM::Value]
    #   the result of the code generation
    def codegen(context)
      context.assign(id.value, value.codegen(context))
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "Assign(#{id.value},#{value})"
    end
  end

  # Represents loading a variable in the AST.
  class Load < Node
    # Value of the node
    #
    # @return [String]
    #   the value of the node
    def value
      text_value
    end

    # Generates the code equivalent to this node. May go down the AST.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [LLVM::LoadInst]
    #   the result of the code generation
    def codegen(context)
      context.load(value)
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "Load(#{value})"
    end
  end

  class Function < Node
    def codegen(context)
      context.function(nil, arguments) do |new_context|
        ret = body.codegen(new_context)
        new_context.return(ret)
      end
    end

    def to_s
      "Function(#{arg.text_value};#{body})"
    end
  end

  # A +Number+ represents a number in the Abstract Syntax Tree.
  class Number < Node
    # Value of the node
    #
    # @return [Fixnum]
    #   the value of the node
    def value
      text_value.to_i
    end

    # Generates the code equivalent to this node.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [LLVM::Value]
    #   the result of the code generation
    def codegen(context)
      context.new_number(value)
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "Number(#{text_value})"
    end
  end
end
