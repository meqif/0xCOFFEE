module Coffee
  class ::Treetop::Runtime::SyntaxNode
    def value
      text_value
    end

    def codegen(context)
    end

    def evaluate
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

    # Evaluates the node in native ruby. May go down the AST.
    #
    # @return [Object, nil]
    #   the result of the evaluation, if any
    def evaluate; end
  end

  class Code < Node
    # Generates the code equivalent to this node. May go down the AST.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [LLVM::ReturnInst]
    #   the result of the code generation
    def codegen(context)
      context.preamble
      value.codegen(context)
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
      ret = value.codegen(context)
      context.return(ret)
    end

    # Evaluates the node in native ruby. May go down the AST.
    #
    # @return [Object, nil]
    #   the result of the evaluation, if any
    def evaluate
      value.evaluate
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "Code(#{value})"
    end
  end

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

    # Evaluates the node in native ruby. May go down the AST.
    #
    # @return [void]
    def evaluate
      puts value.evaluate
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "Print(#{value})"
    end
  end

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

    # Evaluates the node in native ruby. May go down the AST.
    #
    # @return [Object, nil]
    #   the result of the evaluation, if any
    def evaluate
      value.evaluate
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      "#{value}"
    end
  end

  class BinOp < Node
    # @return [Symbol]
    #   the symbol representation of the operator
    def operator
      op.value.to_sym
    end

    # Generates the code equivalent to this node. May go down the AST.
    #
    # @param [Coffee::Generator] context
    # context in which the code is to be generated
    # @return [Object, nil]
    #   the result of the code generation, if any
    def codegen(context)
      context.bin_op(operator, left.codegen(context), right.codegen(context))
    end

    # Evaluates the node in native ruby. May go down the AST.
    #
    # @return [Object, nil]
    #   the result of the evaluation, if any
    def evaluate
      case operator
      when :+
        left.evaluate + right.evaluate
      when :-
        left.evaluate - right.evaluate
      when :*
        left.evaluate * right.evaluate
      when :/
        left.evaluate / right.evaluate
      when :%
        left.evaluate % right.evaluate
      end
    end

    # String representation of this node.
    #
    # @return [String]
    #   the string representation of this node
    def to_s
      case operator
      when :+
        "Addition(#{left},#{right})"
      when :-
        "Subtraction(#{left},#{right})"
      when :*
        "Multiplication(#{left},#{right})"
      when :/
        "Division(#{left},#{right})"
      when :%
        "Modulo(#{left},#{right})"
      end
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

    # Evaluates the node in native ruby.
    #
    # @return [Fixnum]
    #   the result of the evaluation, if any
    def evaluate
      value
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
