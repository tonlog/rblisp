load 'rscheme_info.rb'
require_relative 'env'

class Evaluator

  attr_reader :top_level_env, :current_env

  def initialize(init_info = nil)
    if init_info.nil?
      top_l = Env.new :super_env => nil
      @top_level_env = @current_env = top_l
    else
      @top_level_env = init_info[:top_level]
      @current_env = init_info[:top_level]
    end
  end

  def attach(cur_env)
    cur_env.super_env = @current_env
    @current_env = cur_env
  end

  def detach
    current = @current_env.super_env
    @current_env.escape_env
    @current_env = current
  end

  def eval(expr)
    return if expr.nil?
    begin
      case expr.class.to_s
        when /Array/
          opr = eval(expr[0])
          return if opr.nil?
          raise Exception, opr + RSCHEME_INFO::get_err(:Not_operator) unless !opr.nil? && opr.is_a?(Proc)
          raw_args = expr[1...expr.length]
          args = raw_args.inject([]) do |sum, each_arg|
            sum.push eval(each_arg)
          end
          opr.call(args)
        when /Symbol/
          value_of_sym = @current_env[expr]
          raise Exception, RSCHEME_INFO::get_err(:Undefined_symbol) + expr.to_s if value_of_sym.nil?
          value_of_sym
        else
          expr
      end
    rescue Exception => e
      puts "Error: #{e}"
      return
    end
  end
end


global_env = Env.new :super_env => nil
RSCHEME_INFO::init_global.each_pair do |key, value|
  global_env[key] = value
end
evaluator = Evaluator.new :top_level => global_env
