module RSCHEME_INFO
    require_relative 'pair'
    load '../util/toolkit.rb'

    T = :'#t'
    F = :'#f'

    ERRMSG = {
       :Undefined_symbol => 'unknown value of symbol: ',
       :Not_symbol => 'is not a symbol.',
       :Not_operator => 'is not an operator.',
       :Argument_not_match => 'number args does not match as required. ',
       :Not_pair => ' is not a pair',
    }

    BUILT_IN_SET = [
        :define
    ]

    INIT_GLOBAL = {
        :define => lambda { |args|
                Args = args[:args]
                RSCHEME_INFO::check_arg Args, 1

                env = args[:env]
                evaluator = args[:evaluator]
                symbol_to_define = Args[0]
                value_to_bind = Args[1]

                raise Exception, symbol_to_define + RSCHEME_INFO::get_err(:Not_symbol) unless !symbol_to_define.nil? && symbol_to_define.is_a?(Symbol)
                value_to_bind = evaluator.eval(value_to_bind)
                env[symbol_to_define] = value_to_bind
            },


        :cons => lambda { |args|
                RSCHEME_INFO::check_arg args, 2
                Pair.new args[0], args[1]
            },
        :car => Toolkit::make_pair_func(:car),
        :cdr => Toolkit::make_pair_func(:cdr),
        :cadr => Toolkit::make_pair_func(:cadr),
        :caar => Toolkit::make_pair_func(:caar),
        :cdar => Toolkit::make_pair_func(:cdar),

        :+ => Toolkit::make_num_compu(lambda {|a1,a2| a1 + a2}, value_for_start = 0),
        :- => Toolkit::make_num_compu(lambda {|a1,a2| a1 - a2}, value_for_start = 0),
        :* => Toolkit::make_num_compu(lambda {|a1,a2| a1 * a2}, value_for_start = 1),
        :/ => Toolkit::make_num_compu(lambda {|a1,a2| a1 / a2}, value_for_start = 1, value_for_default = 0),

        :boolean? => lambda { |sym|
                RSCHEME_INFO::check_arg sym, 1
                if sym[0]; T; else F end
            },
    }





    def self.any_built_in? func
        BUILT_IN_SET.any? {|element| element === func}
    end

    def self.init_global
    INIT_GLOBAL
    end

    def self.get_err err_sym
    ERRMSG[err_sym]
    end

    def self.check_arg(args = [], require_num = nil)
        return if require_num.nil?
        raise(Exception, self.get_err(:Argument_not_match) + "\n #{require_num} required but actually passed #{args.length}" ) if args.nil? || args.length != require_num + 1
        true
    end

end

