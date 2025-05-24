module ArelRest::Predications
  class DoesNotMatchOperator
    class << self
      def process(query)
        table = Arel::Table.new(query[:attribute].split(".")[0])
        column = query[:attribute].split(".")[1]
        table[column].does_not_match("%#{query[:values]}%")
      end
    end
  end
end 