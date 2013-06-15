module TYPE_PROCESSOR

    load 'rscheme_info.rb'
    class Processor

        def initialize; end
        private :initialize

        def self.set(args)
            @@evaluator = args[:evaluator]
        end

        def self.process_with(args)
            self.method(args[:type]).call(args)
        end

        def self.array(args)
            expr = args[:expr]
            opr = @@evaluator.eval(expr[0])
            return if opr.nil?
            raise Exception, opr + RSCHEME_INFO::get_err(:Not_operator) unless !opr.nil? && opr.is_a?(Proc)

            if RSCHEME_INFO::any_built_in?(expr[0]); opr.call :args => expr[1..expr.length], :evaluator => @@evaluator, :env => @@evaluator.current_env
            else
                raw_args = expr[1...expr.length]
                pr_args = raw_args.inject([]) do |sum, each_arg|
                    sum.push @@evaluator.eval(each_arg)
                end
                pr_args.push @@evaluator.current_env
                opr.call(pr_args)
            end

        end

        def self.symbol(args)
            expr = args[:expr]

            if expr =~ /'.+/; expr[1..expr.to_s.length-1]
            else
                value_of_sym = @@evaluator.current_env[expr]
                raise Exception, RSCHEME_INFO::get_err(:Undefined_symbol) + expr.to_s if value_of_sym.nil?
                value_of_sym
            end
        end

        def self.other(args)
            args[:expr]
        end
    end
end