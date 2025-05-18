module ArelRest::Predications
  class MatchesOperator
    class << self
      def process(query)
        table = Arel::Table.new(query[:attribute].split(".")[0])
        table[query[:attribute].split(".")[1]].matches("%#{query[:values]}%")
      end
    end
  end
end
