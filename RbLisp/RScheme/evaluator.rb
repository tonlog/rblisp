load 'rscheme_info.rb'
load 'type_processor.rb'
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
        TYPE_PROCESSOR::Processor.set :evaluator => self
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
                when /Array/;   TYPE_PROCESSOR::Processor.process_with :type => :array, :evaluator => self, :expr => expr
                when /Symbol/;  TYPE_PROCESSOR::Processor.process_with :type => :symbol, :evaluator => self, :expr => expr
                else            TYPE_PROCESSOR::Processor.process_with :type => :other, :evaluator => self, :expr => expr
            end
        rescue Exception => e
            puts
            puts "Error: #{e}", $@
            return
        end
    end
end


global_env = Env.new :super_env => nil
RSCHEME_INFO::init_global.each_pair do |key, value|
    global_env[key] = value
end
evaluator = Evaluator.new :top_level => global_env

lam =  evaluator.eval([[:lambda, [:x], [:*, 1.2, :x]], 3])
#print lam.call :params => [], :evaluator => evaluator
print lam



