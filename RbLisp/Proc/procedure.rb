class Procedure
    require_relative '../RScheme/rscheme_info'
    attr_reader :env, :form_params, :body

    def initialize args
        @env = args[:env]
        @form_params = args[:form_params]
        @body = args[:body]
    end

    def call args
        params = args[:params]
        raise Exception, "Arguments does not match. Given #{params.length} for #{@form_params.length} required." unless @form_params.length == params.length
        evaluator = args[:evaluator]

        params.length.times do |count|
            form_param = @form_params[count]
            param_value = params[count]
            @env[form_param] = param_value
        end

        evaluator.attach @env
        result = execute_with evaluator
        evaluator.detach
        result
    end

    def self.extract_form_params params, params_env
        params.each { |form_arg|
            raise Exception, "Error: #{form_arg} is not a valid symbol." unless !form_arg.nil? && form_arg.is_a?(Symbol)
            params_env.push form_arg
        }
        params_env
    end

    def self.extract_body expr, env, closure_env
        return if expr.nil? || !expr.is_a?(Array)
        expr.each { |element|
            redo if element.nil?
            if element.is_a? Symbol
                closure_env[element] = env[element]
            elsif element.is_a? Array
                extract_body element, env, closure_env
            end
        }
        closure_env
    end

    def execute_with evaluator
        raise NotImplementedError, 'Procedure execution not implemented yet.'
    end
    private :execute_with
end