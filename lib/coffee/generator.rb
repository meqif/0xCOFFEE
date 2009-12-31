require "rubygems"
require "llvm"

module Coffee
  class UnknownOperatorError < RuntimeError; end

  class Generator
    include LLVM

    PCHAR      = Type.pointer(Type::Int8Ty)
    INT        = Type::Int32Ty
    NATIVE_INT = MACHINE_WORD

    def initialize(mod = LLVM::Module.new("coffee"), function=nil, arg_names=nil)
      @module   = mod
      @locals   = {}

      @function = function || @module.get_or_insert_function("main", Type.function(NATIVE_INT, [NATIVE_INT, Type.pointer(PCHAR)]))

      arguments = @function.arguments
      if (function.nil? && arg_names.nil?)
        arguments[0].name='argc'
        arguments[1].name='argv'
      end # TODO: Take care of arg_names

      @entry_block = @function.create_block.builder
    end

    def bin_op(op, left, right)
      instruction = case op
      when :+
        Instruction::Add
      when :-
        Instruction::Sub
      when :*
        Instruction::Mul
      when :/
        Instruction::SDiv
      when :%
        Instruction::SRem
      else
        raise UnknownOperatorError, "Unknown Operator: '#{op}'"
      end

      @entry_block.bin_op(instruction, left, right)
    end

    def preamble
      define_external_functions
    end

    def new_string(value)
      @entry_block.create_global_string_ptr(value)
    end

    def new_number(value)
      value.llvm
    end

    def call(func, *args)
      fun = @module.get_function(func)
      @entry_block.call(fun, *args)
    end

    def assign(name, value)
      ptr = @entry_block.alloca(value_type(value), 0)
      @entry_block.store(value, ptr)
      @locals[name] = ptr
    end

    def load(name)
      @entry_block.load(@locals[name])
    end

    def function(name)
      func = @module.get_or_insert_function(name, Type.function(NATIVE_INT, []))
      generator = Generator.new(@module, func)
      yield generator
    end

    def return(value)
      @entry_block.return(value)
    end

    def optimize
      PassManager.new.run(@module)
    end

    def run
      ExecutionEngine.get(@module)
      ExecutionEngine.run_function_autoconvert(@function, 0, 0)
    end

    def is_terminated?
      @function.get_basic_block_list[0].get_instruction_list[-1].class == LLVM::ReturnInst
    end

    # Writes generated LLVM-IR to a file.
    #
    # @param file
    #   path to the destination file
    # @return [Fixnum]
    #   how many characters were written
    def to_file(file)
      File.open(file, 'w') {|f| f.write(@module.inspect) }
    end

    # Writes generated bitcode to a file.
    #
    # @param [String] file
    #   path to the destination file
    # @return [Bool]
    #   whether the write was successful
    def write_bitcode(file)
      @module.write_bitcode(file)
    end

    def inspect
      @module.inspect
    end

    private
      def define_external_functions
        @module.external_function("printf", Type.function(NATIVE_INT, [PCHAR], true))
        @module.external_function("puts", Type.function(INT, [PCHAR]))
        @module.external_function("read", Type.function(INT, [INT, PCHAR, INT]))
        @module.external_function("exit", Type.function(INT, [INT]))
      end

      TYPE_MAPPING = { 11 => PCHAR, 7 => NATIVE_INT }
      def value_type(value)
        TYPE_MAPPING[value.type.type_id]
      end
  end
end
