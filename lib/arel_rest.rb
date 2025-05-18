module ArelRest
  require 'active_record'
	require 'json_api_filter_adapter/eq_operator'
  require 'json_api_filter_adapter/gt_operator'
  require 'json_api_filter_adapter/gteq_operator'
  require 'json_api_filter_adapter/lt_operator'
  require 'json_api_filter_adapter/lteq_operator'
  require 'json_api_filter_adapter/in_operator'
  require 'json_api_filter_adapter/not_in_operator'
  require 'json_api_filter_adapter/between_operator'
  require 'json_api_filter_adapter/matches_operator'

  TEMPLATE_OPERATORS = {
    "eq" => JsonApiFilterAdapter::EqOperator,
    "gt" => JsonApiFilterAdapter::GtOperator,
    "gteq" => JsonApiFilterAdapter::GteqOperator,
    "lt" => JsonApiFilterAdapter::LtOperator,
    "lteq" => JsonApiFilterAdapter::LteqOperator,
    "in" => JsonApiFilterAdapter::InOperator,
    "not_in" => JsonApiFilterAdapter::NotInOperator,
    "between" => JsonApiFilterAdapter::BetweenOperator,
    "matches" => JsonApiFilterAdapter::MatchesOperator,
  }

  class << self
    attr_accessor :time_zone
  end

  # Recevi object query and return array with
  # string query and value.
  # Ex: query object: {attribute: "a", operator:"=", values: [1]}
  # >> ["a = ?", [1]]

  class OperatorNotFound < StandardError
    attr_accessor :column

    def initialize(column)
      @column = column
      super
    end

    def message
      "Operator #{@column} not found"
    end
  end

  def build_pair_query_string_and_values(q)
    operator = TEMPLATE_OPERATORS[q[:operator].to_s]

    raise(OperatorNotFound, q[:operator].to_s) unless operator

    operator.process(q)
  end

  def query_builder(query)
    conector = query.keys.detect{|connector| [:or, :and].include?(connector.to_sym)}
    pair_query_string_and_values = query[conector].map do |query_obj|
      if query_obj.keys.map(&:to_sym).any?{|key| [:or,:and].include?(key)}
        nested_query = query_builder(query_obj) # Recursive
        builded = nested_query
      else
        builded = build_pair_query_string_and_values(query_obj)
      end

      builded
    end.inject do |query_composited, query_node|
      if query_composited.nil?
        query_composited = query_node
      else
        query_composited = query_composited.send(conector, query_node)
      end
      query_composited
    end

    pair_query_string_and_values
  end

  def parse_filter_to_arel(query)
    query_builder(query)
  end
    
end
