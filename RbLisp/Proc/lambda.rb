require_relative 'procedure'
class Lambda < Procedure
    def execute_with evaluator
        exec_result = nil
        @body.each do |each_statement|
            exec_result = evaluator.eval each_statement
        end
        exec_result
    end
end