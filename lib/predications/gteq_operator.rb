module ArelRest::Predications
  class GteqOperator
    class << self
      def process(query)
        table = Arel::Table.new(query[:attribute].split(".")[0])
        column = query[:attribute].split(".")[1]

        table[column].gteq(query[:values])
      end
    end
  end
end