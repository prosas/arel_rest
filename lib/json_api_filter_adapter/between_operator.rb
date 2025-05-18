module JsonApiFilterAdapter
  class BetweenOperator
    class << self
      def process(query)
        table = Arel::Table.new(query[:attribute].split(".")[0])
        column = query[:attribute].split(".")[1]

        range = Range.new(
          transform_data_for_first(query[:values][0]),
          transform_data_for_last(query[:values][1])
          )
        table[column].between(range)
      end

      private

      def transform_data_for_first(first)
        case first
        when /^\d{4}-\d{2}-\d{2}$/ # somente com data
          Time.use_zone(ArelRest.time_zone) { Time.zone.parse(first).beginning_of_day }
        when /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/ # com data e hora
          Time.use_zone(ArelRest.time_zone) { Time.zone.parse(first) }
        when /^\d{4}-\d{2}-\d{2} \d{2}:\d{2} \S+$/ # com data, hora e fuso horário
          Time.use_zone(ArelRest.time_zone) { Time.zone.parse(first) }
        else
          first
        end
      end

      def transform_data_for_last(last)
        case last
        when /^\d{4}-\d{2}-\d{2}$/ # somente com data
          Time.use_zone(ArelRest.time_zone) { Time.zone.parse(last).end_of_day }
        when /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/ # com data e hora
          Time.use_zone(ArelRest.time_zone) { Time.zone.parse(last) }
        when /^\d{4}-\d{2}-\d{2} \d{2}:\d{2} \S+$/ # com data, hora e fuso horário
          Time.use_zone(ArelRest.time_zone) { Time.zone.parse(last) }
        else
          last
        end
      end

    end
  end
end