require 'predications/eq_operator'
require 'predications/not_eq_operator'
require 'predications/gt_operator'
require 'predications/gteq_operator'
require 'predications/lt_operator'
require 'predications/lteq_operator'
require 'predications/in_operator'
require 'predications/not_in_operator'
require 'predications/between_operator'
require 'predications/matches_operator'
require 'predications/does_not_match_operator'
require 'predications/order_operator'

module ArelRest
	class Parser
	  TEMPLATE_OPERATORS = {
	    "eq" => Predications::EqOperator,
	    "not_eq" => Predications::NotEqOperator,
	    "gt" => Predications::GtOperator,
	    "gteq" => Predications::GteqOperator,
	    "lt" => Predications::LtOperator,
	    "lteq" => Predications::LteqOperator,
	    "in" => Predications::InOperator,
	    "not_in" => Predications::NotInOperator,
	    "between" => Predications::BetweenOperator,
	    "matches" => Predications::MatchesOperator,
	    "does_not_match" => Predications::DoesNotMatchOperator,
	  }

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

	  def self.build_pair_query_string_and_values(q)
	    operator = TEMPLATE_OPERATORS[q[:operator].to_s]

	    raise(Parser::OperatorNotFound, q[:operator].to_s) unless operator

	    operator.process(q)
	  end

	  def self.query_builder(query)
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

	  def self.parse_filter_to_arel(query)
	    query_builder(query)
	  end
	end
end