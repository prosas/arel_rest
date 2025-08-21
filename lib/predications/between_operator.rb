module ArelRest::Predications
  class BetweenOperator
    class << self
      def process(query)
        table = Arel::Table.new(query[:attribute].split(".")[0])
        column = query[:attribute].split(".")[1]

        range = Range.new(
          try_transform_date(query[:values][0]),
          try_transform_date(query[:values][1])
          )
        table[column].between(range)
      end

      private

      def try_transform_date(date)
        begin
          Time.use_zone(ArelRest.time_zone) { Time.parse(date)}
        rescue StandardError => e
          date
        end
      end

    end
  end
end