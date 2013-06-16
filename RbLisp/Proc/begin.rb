require_relative 'procedure'
class Begin < Procedure
    def execute_with evaluator
        @body.each { |each_exe_body|
            evaluator.eval each_exe_body
        }
    end
end