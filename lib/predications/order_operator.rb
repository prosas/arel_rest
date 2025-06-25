module ArelRest::Predications
  class OrderOperator
    class << self
      def process(query)
        table = Arel::Table.new(query[:attribute].split(".")[0])
        column = query[:attribute].split(".")[1]
        
        return table[column].asc if query[:values] == 'asc'
        return table[column].desc if query[:values] == 'desc'
      end
    end
  end
end