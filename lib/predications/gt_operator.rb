module ArelRest::Predications
  class GtOperator
    class << self
      def process(query)
        table = Arel::Table.new(query[:attribute].split(".")[0])
        column = query[:attribute].split(".")[1]

        table[column].gt(query[:values])
      end
    end
  end
end