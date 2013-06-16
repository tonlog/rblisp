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
            raise Exception, opr.to_s + RSCHEME_INFO::get_err(:Not_operator) unless !opr.nil? && (opr.is_a?(Proc) || opr.is_a?(Lambda))

            if RSCHEME_INFO::any_built_in?(expr[0])
                opr.call :params => expr[1..expr.length], :evaluator => @@evaluator
            else
                raw_args = expr[1...expr.length]
                pr_args = raw_args.inject([]) do |sum, each_arg|
                    v = @@evaluator.eval(each_arg)
                    sum.push v
                end
                pr_args = [] if pr_args.nil? || (pr_args.length == 1 && pr_args[0].nil?)
                pr_args = expr.is_a?(Array) && expr.length == 1? nil : pr_args
                opr.call :params => pr_args, :evaluator => @@evaluator
            end

        end

        def self.symbol(args)
            expr = args[:expr]

            if expr =~ /'.+/; expr[1..expr.to_s.length-1]
            else
=begin
                puts '>>>> for symbol .. '+ @@evaluator.current_env.to_s
                puts '>>>> current env class : ' + @@evaluator.current_env.class.to_s
                puts '>>>> current super env is : ' + @@evaluator.current_env.super_env.to_s
                puts '>>>> current super super env is : ' + @@evaluator.current_env.super_env.super_env.to_s unless @@evaluator.current_env.super_env.nil?
=end

                value_of_sym = @@evaluator.current_env[expr]
                raise Exception, RSCHEME_INFO::get_err(:Undefined_symbol) + expr.to_s if value_of_sym.nil?
                value_of_sym
            end
        end

        def self.other(args); args[:expr] end

    end
end