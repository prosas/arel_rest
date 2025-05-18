module JsonApiFilterAdapter
  class NotInOperator
    class << self
      def process(query)
        values = query[:values].dup.map{|value| value==('=null=') ? nil : value}

        table = Arel::Table.new(query[:attribute].split(".")[0])
        table[query[:attribute].split(".")[1]].not_in(values)
      end
    end
  end
end