module ArelRest::Predications
  class NotEqOperator
    class << self
      def process(query)
        values = query[:values] == '=null=' ? nil : query[:values]
        
        table = Arel::Table.new(query[:attribute].split(".")[0])
        column = query[:attribute].split(".")[1]
        table[column].not_eq(values)
      end
    end
  end
end 