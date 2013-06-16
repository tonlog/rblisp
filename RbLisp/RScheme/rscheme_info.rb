module RSCHEME_INFO
    require_relative 'pair'
    require_relative 'env'
    require_relative '../Proc/lambda'
    require_relative 't'
    load '../util/toolkit.rb'

    ERRMSG = {
       :Undefined_symbol => 'unknown value of symbol: ',
       :Not_symbol => ' is not a symbol.',
       :Not_operator => ' is not an operator.',
       :Argument_not_match => 'number args does not match as required. ',
       :Not_pair => ' is not a pair',
    }

    BUILT_IN_SET = [
        :define,
        :lambda,
        :cond,
        :begin,
        :let,
    ]

    INIT_GLOBAL = {
        :lambda => lambda { |args|
            evaluator = args[:evaluator]
            expr = args[:params]
            raise Exception, 'Missing arg_list and body.' if expr.nil? || expr.length < 2
            arg_list = expr[0]
            body = expr[1..expr.length]
            form_params = Lambda.extract_form_params arg_list, []
            closure_env = Lambda.extract_body body, evaluator.current_env, Env.new(:super_env => nil)

            Lambda.new :env => closure_env, :form_params => form_params, :body => body
        },

        :begin => lambda { |args|
            #begin can be seen as a pure lambda => which executes without args and sequentially executed itself..
            evaluator = args[:evaluator]
            expr = args[:params]
            if expr.nil? ;
                nil
            elsif expr.is_a? Array
                opr = INIT_GLOBAL[:lambda]
                form_params = []
                params = [form_params]
                expr.each { |sub_body|
                    params.push sub_body
                }

                params.push nil if params.length < 2
                begin_exec = opr.call :evaluator => evaluator, :params => params
                begin_exec.call :evaluator => evaluator, :params => nil
            end
        },

        :cond => lambda { |args|
            evaluator = args[:evaluator]
            expr = args[:params]
            if expr.nil?
                RSCHEME_INFO::F
            elsif expr.is_a? Array
                exec_result = nil
                expr.each do |each_test_exec_pair|
                    raise Exception, "The Test-Exec does not match requirement. Check #{each_test_exec_pair}" unless each_test_exec_pair.is_a?(Array) && each_test_exec_pair.length == 2
                    test_clause, exec_clause = each_test_exec_pair[0], each_test_exec_pair[1]
                    test_result = evaluator.eval test_clause
                    exec_result = evaluator.eval exec_clause;break unless test_result == RSCHEME_INFO::F
                end
                exec_result
            end





        },

        :define => lambda { |args|
            evaluator = args[:evaluator]
            expr = args[:params]
            raise Exception, "Given parameters does not match syntax." if expr.nil? || expr.length < 1

            var = expr[0]
            if var.is_a?(Symbol) && expr.length != 2
                #if the given variable is a symbol,then it is the form: (define var value)
                value_body = expr[1]
                value_to_bind = evaluator.eval value_body
                evaluator.current_env[var] = value_to_bind
                "variable #{var} is defined."
            elsif var.is_a?(Array) && var.length > 0 && expr.length > 1
                #if the given one is in the form of pair, then it is about to define a process, in this case we may use lambda instead,
                #which means define now is the syntax sugar of lambda, binding anonymous lambda with a var-name
                proc_name, form_params = var[0], var[1..var.length]
                lambda_opr, value_body = INIT_GLOBAL[:lambda], expr[1..expr.length]
                params = [form_params]
                value_body.each {|exec_subbody| params.push exec_subbody}
                prodecure_to_define = lambda_opr.call :evaluator => evaluator, :params => params
                evaluator.current_env[proc_name] = prodecure_to_define
                "variable #{var[0]} is defined."
            else
                raise Exception,"Invalid variables given in Define. Check #{var}"
            end
            },

        :let => lambda { |args|
            evaluator = args[:evaluator]
            expr = args[:params]

            raise Exception,"Invalid syntax body of let." if expr.nil? || !expr.is_a?(Array) || expr.length < 2

            closure_env = Env.new :super_env => nil
            k_v_set = expr[0]
            k_v_set.each { |k_v_pair|
                key, value = k_v_pair[0], k_v_pair[1]
                raise Exception,"#{key} is not a symbol." unless key.is_a?(Symbol)
                closure_env[key] = value
            }

            evaluator.attach closure_env
            opr = INIT_GLOBAL[:lambda]
            form_params = []
            params = [form_params]
            expr[1..expr.length].each { |sub_body|
                params.push sub_body
            }

=begin
            puts params.inspect + "@line130 of rinfo"
            puts opr.inspect + "@line131 of rinfo"
            puts closure_env.inspect + "@line132 of rinfo"
=end

            let_exec = opr.call :evaluator => evaluator, :params => params
            result =  let_exec.call :evaluator => evaluator, :params => nil
            evaluator.detach
            result
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

        :and => lambda { |args|
            evaluator = args[:evaluator]
            params = args[:params]

            if  params.nil?; T
            elsif params
                return_value = nil
                params.each { |each_predicate|
                    return_value = evaluator.eval each_predicate
                    break unless return_value
                }
                return_value || 'NIL'
            end
        },
        :or => lambda { |args|
            evaluator = args[:evaluator]
            params = args[:params]

            if  params.nil?; T
            elsif params
                return_value = nil
                params.each { |each_predicate|
                    return_value = evaluator.eval each_predicate
                    break if return_value
                }
                return_value || 'NIL'
            end
        },
        :not => lambda { |args|
            evaluator = args[:evaluator]
            params = args[:params]

            raise Exception, "not operator expects 1 arg. But #{params.nil? ? 'none' : params.length} is given." if params.nil? || params.length != 1

            arg = params[0]
            if evaluator.eval(arg); F else T end
        },

        :+ => Toolkit::make_num_compu(lambda {|a1,a2| a1 + a2}, value_for_start = 0, value_for_default = 0),
        :- => Toolkit::make_num_compu(lambda {|a1,a2| a1 - a2}, value_for_start = 0, value_for_default = 0),
        :* => Toolkit::make_num_compu(lambda {|a1,a2| a1 * a2}, value_for_start = 1,value_for_default = 1),
        :/ => Toolkit::make_num_compu(lambda {|a1,a2| a1 / a2}, value_for_start = 1, value_for_default = 0),

        :boolean? => lambda { |sym|
                RSCHEME_INFO::check_arg sym, 1
                if sym[0]; T else F end
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

