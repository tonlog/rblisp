require_relative 'procedure'
class Lambda < Procedure
    def execute_with evaluator; evaluator.eval @body  end
end