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
=begin
        puts '>> Attach and current is: ' + @current_env.to_s
        puts '>> super is ' + @current_env.super_env.to_s
=end
    end

    def detach
        current = @current_env.super_env
        @current_env.escape_env
        @current_env = current
=begin
        puts '>> Detach and current is:  ' + @current_env.to_s
        puts '>> super is ' + @current_env.super_env.to_s
=end
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
            puts "Error: #{e}"#, $@
            return
        end
    end
end


global_env = Env.new :super_env => nil
RSCHEME_INFO::init_global.each_pair do |key, value|
    global_env[key] = value
end
evaluator = Evaluator.new :top_level => global_env

#lam = evaluator.eval [[:lambda, [], [:+, 1, 1], [:+, 2, 3], [:+, 3, 8]]]
lam = evaluator.eval [:+]
lam = evaluator.eval [:let, [[:x, 5], [:y, 3]], [:define, [:f, :x, :y], [:*, :y, :x]], [:f, :x, :y]]
print lam, "\n"

puts evaluator.eval [:and, 1, 2]
puts evaluator.eval [:and, 1, nil, 2]
puts evaluator.eval [:or, false, false, [:+, 2, 3]]
puts evaluator.eval [:not, false]
puts evaluator.eval [:not]



