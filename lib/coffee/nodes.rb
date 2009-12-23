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
      value.codegen(g)
      g.finish
    end

    def evaluate
      value.evaluate
    end

    def to_s
      "Code(#{value})"
    end
  end

  class Print < Node
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

  class Addition < Node
    def codegen(g)
    end

    def evaluate
      left.evaluate + right.evaluate
    end

    def to_s
      "Addition(#{left},#{right})"
    end
  end

  class Subtraction < Node
    def codegen(g)
    end

    def evaluate
      left.evaluate - right.evaluate
    end

    def to_s
      "Subtraction(#{left},#{right})"
    end
  end

  class Multiplication < Node
    def codegen(g)
    end

    def evaluate
      left.evaluate * right.evaluate
    end

    def to_s
      "Multiplication(#{right},#{right})"
    end
  end

  class Division < Node
    def evaluate
      left.evaluate / right.evaluate
    end

    def to_s
      "Division(#{left},#{right})"
    end
  end

  class Modulo < Node
    def evaluate
      left.evaluate % right.evaluate
    end

    def to_s
      "Modulo(#{left},#{right})"
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