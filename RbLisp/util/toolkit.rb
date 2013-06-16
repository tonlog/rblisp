module Toolkit
    extend self

    def map_with_(file_name, map_action, rescue_action, extra_action = nil)
    raise Exception unless map_action.is_a?(Proc) &&
        rescue_action.is_a?(Proc) &&
        map_action.parameters.length > 0
    lambda do
      begin
        (f = File.open file_name).each {|each_line| map_action.call(each_line)}
        rescue Exception
          rescue_action.call
        ensure
          f.close unless f.nil?
          extra_action.call if !extra_action.nil? && extra_action.is_a?(Proc)
      end
    end
    end

    def make_num_compu(opr, value_for_start = nil, value_for_default = nil, debug = nil)
    lambda {|maps|
        args = maps[:params]

        if !args.nil? && (args.is_a?(Array) && args.length > 1)
            for_start = args[0]
            args = args[1..args.length-1]
            args.each { |arg| for_start = opr.call(for_start, arg)}
            for_start
        elsif !args.nil? && args.length == 1
            opr.call(value_for_start,args[0])
        else
            value_for_default || 0
        end
    }
    end

    def make_pair_func(opr_sym, default_args_num = 1)
        lambda { |args|
            RSCHEME_INFO::check_arg args, default_args_num
            raise Exception,self.get_err(:Not_pair) unless args[0].is_a? Pair
            args[0].method(opr_sym).call
        }
    end


end