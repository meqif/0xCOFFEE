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
  end

  class Expression < Node
    def codegen(g)
    end

    def evaluate
      value.evaluate
    end
  end

  class Addition < Node
    def codegen(g)
    end

    def evaluate
      multiplication.evaluate + addition.evaluate
    end
  end

  class Subtraction < Node
    def codegen(g)
    end

    def evaluate
      multiplication.evaluate - addition.evaluate
    end
  end

  class Multiplication < Node
    def codegen(g)
    end

    def evaluate
      primary.evaluate * multiplication.evaluate
    end
  end

  class Number < Node
    def codegen(g)
      g.new_number(value)
    end

    def evaluate
      text_value.to_i
    end
  end
end