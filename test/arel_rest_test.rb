require "minitest/autorun"
require 'arel_rest'
require 'active_support/all'
require 'byebug'
require_relative './db_setup'

class ArelRestTest < Minitest::Test

  class TestClassV2
    include ArelRest
  end

  def setup
    @_classV2 = TestClassV2.new
    ArelRest.time_zone = 'America/Sao_Paulo'
  end

  def test_parse_filter_adapter_v2_not_found_operator
    assert_raises ArelRest::OperatorNotFound do
      @_classV2.parse_filter_to_arel({
        "and" => [{attribute: "row.colum1", operator:"not_exist_operator_xpto", values: [20]}]
      })
    end
  end

  def test_parse_filter_adapter_v2
    assert_equal @_classV2.parse_filter_to_arel({
      "and" => [
        {attribute: "row.colum1", operator:"eq", values: 20},
        {attribute: "row.colum2", operator:"in", values: ["=null=","teste"]}
      ]
    }).to_sql,"\"row\".\"colum1\" = 20 AND \"row\".\"colum2\" IN (NULL, 'teste')"

    assert_equal @_classV2.parse_filter_to_arel({
      "and" => [
        {attribute: "row.colum1", operator:"eq", values: 20},
        {attribute: "row.colum2", operator:"in", values: ["=null="]}
      ]
    }).to_sql,"\"row\".\"colum1\" = 20 AND \"row\".\"colum2\" IN (NULL)"
  end

  def test_parse_filter_adpater_v2_nested_or
    assert_equal @_classV2.parse_filter_to_arel({
      "and" => [
        {attribute: "row.colum1", operator:"in", values: ["blue"]},
        "or" => [
          {attribute: "row.colum2", operator:"eq", values: "black"},
          {attribute: "row.colum2", operator:"eq", values: "orange"}
        ]
      ]
    }).to_sql, "\"row\".\"colum1\" IN ('blue') AND (\"row\".\"colum2\" = 'black' OR \"row\".\"colum2\" = 'orange')"
  end

  def test_parse_filter_adpater_v2_nested_and
    assert_equal @_classV2.parse_filter_to_arel({
      "or" => [
        {attribute: "row.colum1", operator:"in", values: ["blue"]},
        "and" => [
          {attribute: "row.colum2", operator:"eq", values: "black"},
          {attribute: "row.colum3", operator:"eq", values: "orange"}
        ]
      ]
    }).to_sql, "(\"row\".\"colum1\" IN ('blue') OR \"row\".\"colum2\" = 'black' AND \"row\".\"colum3\" = 'orange')"
  end

  def test_less_than_number_v2
    assert_equal @_classV2.parse_filter_to_arel({"and" => [{attribute: "row.colum1", operator: "lt", values: 202}]}).to_sql,
      "\"row\".\"colum1\" < 202"
  end

  def test_less_than_string_v2
    assert_equal @_classV2.parse_filter_to_arel({"and" => [{attribute: "row.colum1", operator: "lt", values: "'2024-01-01 14:10'"}]}).to_sql,
      "\"row\".\"colum1\" < '''2024-01-01 14:10'''"
  end

  def test_contains_v2
    assert_equal @_classV2.parse_filter_to_arel({"and" => [{attribute: "row.colum1", operator: "matches", values: "some things" }]}).to_sql,
      "\"row\".\"colum1\" LIKE '%some things%'"
  end

  def test_in_v2
    assert_equal @_classV2.parse_filter_to_arel({"and" => [{attribute: 'row.colum1', operator: 'in', values: [1,2,3]}]}).to_sql,
     "\"row\".\"colum1\" IN (1, 2, 3)"
  end

  def test_not_in_v2
    assert_equal @_classV2.parse_filter_to_arel({"and" => [{attribute: 'row.colum1', operator: 'not_in', values: [1,2,3]}]}).to_sql,
     "\"row\".\"colum1\" NOT IN (1, 2, 3)"
  end

  def test_lesser_equal_than_string_v2
    assert_equal @_classV2.parse_filter_to_arel({"and" => [{attribute: "row.colum1", operator: "lteq", values: "'2024-01-01 14:10'" }]}).to_sql,
      "\"row\".\"colum1\" <= '''2024-01-01 14:10'''"
  end

  def test_greater_than_number_v2
    assert_equal @_classV2.parse_filter_to_arel({"and" => [{attribute: "row.colum1", operator: "gt", values: "202"}]}).to_sql,
      "\"row\".\"colum1\" > '202'"
  end

  def test_greater_than_string_v2
    assert_equal @_classV2.parse_filter_to_arel({"and"=>[{attribute: "row.colum1", operator: "gt", values: "'2024-01-01 14:10'"}]}).to_sql,
      "\"row\".\"colum1\" > '''2024-01-01 14:10'''"
  end

  def test_greater_equal_than_string_v2
    assert_equal @_classV2.parse_filter_to_arel({"and"=>[{attribute: "row.colum1", operator: "gteq", values: "'2024-01-01 14:10'"}]}).to_sql,
      "\"row\".\"colum1\" >= '''2024-01-01 14:10'''"
  end

  def test_initializer_sets_time_zone_v2
    assert_equal 'America/Sao_Paulo', ArelRest.time_zone
  end

  def test_range_with_dates_hours_and_time_zone_v2
    ArelRest.time_zone = ActiveSupport::TimeZone['America/Sao_Paulo']
    assert_equal @_classV2.parse_filter_to_arel({
      "and" => [{ attribute: "row.colum1", operator:"between", values: ["2024-09-10T00:00:00", "2024-09-10T23:59:00"] }]
    }).to_sql,
    "\"row\".\"colum1\" BETWEEN '2024-09-10 03:00:00' AND '2024-09-11 02:59:00'"
  end

end