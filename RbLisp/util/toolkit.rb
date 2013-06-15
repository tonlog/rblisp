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

  def make_num_compu(opr, value_for_start = nil, value_for_nonargs = nil, debug = nil)
    lambda {|args|
      puts args.inspect
      if !args.nil? && (args.is_a?(Array) && args.length > 0)
        return opr.call(value_for_start,args[0]) if args.length == 1

        for_start = args[0]
        print 'sta:',for_start, "\n" if debug.nil?
        args[1...args.length].each { |arg| for_start = opr.call(for_start, arg)}
        for_start
      else
        value_for_nonargs || 0
      end
    }
  end

end