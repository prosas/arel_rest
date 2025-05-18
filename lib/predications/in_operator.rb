module ArelRest::Predications
  class InOperator
    class << self
      def process(query)
        values = query[:values].dup.map{|value| value==('=null=') ? nil : value}

        table = Arel::Table.new(query[:attribute].split(".")[0])
        table[query[:attribute].split(".")[1]].in(values)
      end
    end
  end
end