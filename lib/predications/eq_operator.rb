module ArelRest::Predications
  class EqOperator
    class << self
      def process(query)
        table = Arel::Table.new(query[:attribute].split(".")[0])
        table[query[:attribute].split(".")[1]].eq(query[:values])
      end
    end
  end
end
