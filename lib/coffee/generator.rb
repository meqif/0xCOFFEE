require "rubygems"
require "llvm"

module Coffee
  class Generator
    include LLVM

    PCHAR      = Type.pointer(Type::Int8Ty)
    INT        = Type::Int32Ty
    NATIVE_INT = MACHINE_WORD
    OP_INSTRUCTIONS = { :+ => Instruction::Add, :- => Instruction::Sub,
                        :* => Instruction::Mul, :/ => Instruction::SDiv,
                        :% => Instruction::SRem }

    @@anonymous_functions = -1

    def initialize(mod = LLVM::Module.new("coffee"), function=nil, arg_names=['argc','argv'])
      @module   = mod
      @locals   = {}

      @function = function || @module.get_or_insert_function("main", Type.function(NATIVE_INT, [NATIVE_INT, Type.pointer(PCHAR)]))
      @entry_block = @function.create_block.builder

      arguments = @function.arguments

      count = 0
      arg_names.each do |arg_name|
        arguments[count].name = arg_name
        assign(arg_name, arguments[count])
        count += 1
      end

    end

    def bin_op(op, left, right)
      @entry_block.bin_op(OP_INSTRUCTIONS[op], left, right)
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
      raise RuntimeError if name.nil?
      ptr = @entry_block.alloca(value_type(value), 0)
      ptr.name = name
      @entry_block.store(value, ptr)
      @locals[name] = ptr
    end

    def load(name)
      @entry_block.load(@locals[name])
    end

    def function(name, args)
      name ||= "_f#{@@anonymous_functions += 1}"
      func = @module.get_or_insert_function(name, Type.function(NATIVE_INT, args.map {NATIVE_INT} ))
      generator = Generator.new(@module, func, args)
      yield generator
      raise RuntimeError unless function_terminated? func
      func
    end

    def return(value)
      raise RuntimeError unless value.type.type_id == @function.return_type.type_id
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
      function_terminated? @function
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

      TYPE_MAPPING = { Type.pointer(PCHAR).to_s.to_sym => Type.pointer(PCHAR),
                       PCHAR.to_s.to_sym => PCHAR,
                       NATIVE_INT.to_s.to_sym => NATIVE_INT }
      def value_type(value)
        if value.class == LLVM::Function
          sig = value.type.to_s.partition(' ')
          ret = TYPE_MAPPING[sig.first.to_sym]
          args = sig.last.match(/(\w+)/).to_a.map {|type| TYPE_MAPPING[type.to_sym] }
          type = Type.pointer(Type.function(ret, args))
        else
          TYPE_MAPPING[value.type.to_s.to_sym]
        end
      end

      def function_terminated?(function)
        function.get_basic_block_list[0].get_instruction_list[-1].class == LLVM::ReturnInst
      end
  end
end
