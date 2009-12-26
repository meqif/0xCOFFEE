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
    # @param [Coffee::Generator] g
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
    # @param [Coffee::Generator] g
    # context in which the code is to be generated
    # @return [Object, nil]
    #   the result of the code generation, if any
    def codegen(g)
      g.preamble
      value.codegen(g)
      g.return(0.llvm)
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
    # @param [Coffee::Generator] g
    # context in which the code is to be generated
    # @return [Object, nil]
    #   the result of the code generation, if any
    def codegen(g)
      str = g.new_string("%d\n")
      g.call("printf", str, value.codegen(g))
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
    # @param [Coffee::Generator] g
    # context in which the code is to be generated
    # @return [Object, nil]
    #   the result of the code generation, if any
    def codegen(g)
      value.codegen(g)
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
    # @param [Coffee::Generator] g
    # context in which the code is to be generated
    # @return [Object, nil]
    #   the result of the code generation, if any
    def codegen(g)
      g.bin_op(operator, left.codegen(g), right.codegen(g))
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
    # @param [Coffee::Generator] g
    # context in which the code is to be generated
    # @return [LLVM::Value]
    #   the result of the code generation
    def codegen(g)
      g.new_number(value)
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
