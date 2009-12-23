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
    def value
      expression
    end

    def codegen(g)
    end

    def evaluate
      value.evaluate
    end

    def to_s
      "#{value}"
    end
  end

  class Print < Node
    def evaluate
      puts expression.evaluate
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
      multiplication.evaluate + addition.evaluate
    end

    def to_s
      "Addition(#{multiplication},#{addition})"
    end
  end

  class Subtraction < Node
    def codegen(g)
    end

    def evaluate
      multiplication.evaluate - addition.evaluate
    end

    def to_s
      "Subtraction(#{multiplication},#{addition})"
    end
  end

  class Multiplication < Node
    def codegen(g)
    end

    def evaluate
      primary.evaluate * multiplication.evaluate
    end

    def to_s
      "Multiplication(#{primary},#{multiplication})"
    end
  end

  class Division < Node
    def evaluate
      primary.evaluate / multiplication.evaluate
    end

    def to_s
      "Division(#{primary},#{multiplication})"
    end
  end

  class Modulo < Node
    def evaluate
      primary.evaluate % multiplication.evaluate
    end

    def to_s
      "Modulo(#{primary},#{multiplication})"
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