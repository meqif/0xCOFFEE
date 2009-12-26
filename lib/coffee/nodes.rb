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
  Node = Treetop::Runtime::SyntaxNode

  class Code < Node
    def codegen(g)
      g.preamble
      value.codegen(g)
      g.return(0.llvm)
    end

    def evaluate
      value.evaluate
    end

    def to_s
      "Code(#{value})"
    end
  end

  class Print < Node
    def value
      expression
    end

    def codegen(g)
      #str = g.new_string("Olá!\n")
      str = g.new_string("%d\n")
      g.call("printf", str, value.codegen(g))
    end

    def evaluate
      puts value.evaluate
    end
  end

  class Expression < Node
    def codegen(g)
      value.codegen(g)
    end

    def evaluate
      value.evaluate
    end

    def to_s
      "#{value}"
    end
  end

  class BinOp < Node
    def op
      operator.value.to_sym
    end

    def codegen(g)
      g.bin_op(op, left.codegen(g), right.codegen(g))
    end

    def evaluate
      case op
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

    def to_s
      case op
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

  class Number < Node
    def value
      text_value.to_i
    end

    def codegen(g)
      g.new_number(value)
    end

    def evaluate
      value
    end

    def to_s
      "Number(#{text_value})"
    end
  end
end