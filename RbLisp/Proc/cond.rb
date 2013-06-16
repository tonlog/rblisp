require_relative 'procedure'
class Cond < Procedure
    def execute_with evaluator
        @body.each do |each_statement|
            raise Exception, '' unless !each_statement.nil? && each_statement.is_a?(Array) && each_statement.length == 2
            if evaluator.eval(each_statement[0]) == RSCHEME_INFO::T
                evaluator.eval each_statement[1]
                return
            end
        end
    end
end