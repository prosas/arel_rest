require "minitest/autorun"
require 'json_api_active_record_query_adapter'
require 'active_support/all'
require 'byebug'

class JsonApiFilterAdapterTest < Minitest::Test
  class TestClass
    include JsonApiFilterAdapter
  end

  def setup
    @_class = TestClass.new
    JsonApiFilterAdapter.time_zone = 'America/Sao_Paulo'
  end

  def test_parse_filter_adapter
    assert_equal @_class.parse_filter_adapter({"row.colum1" => 20, "row.colum2" => ["=null=", "teste"]}),["row.colum1 = ? AND (row.colum2 IS NULL OR row.colum2 IN (?))", "20", ["teste"]]

    assert_equal @_class.parse_filter_adapter({"row.colum1" => 20, "row.colum2" => "=null="}),["row.colum1 = ? AND row.colum2 IS NULL", "20"]

    assert_equal @_class.parse_filter_adapter({"row.colum1" => 20, "row.colum2" => "=like=teste"}),["row.colum1 = ? AND row.colum2 LIKE ?", "20", "%teste%"]
  end

  def test_less_than_number
    assert_equal @_class.parse_filter_adapter({"row.colum1" => "< 202"}) ,
      ["row.colum1 < ?", "202"]
  end

  def test_less_than_string
    assert_equal @_class.parse_filter_adapter({"row.colum1" => "< '2024-01-01 14:10'"}),
      ["row.colum1 < ?", "'2024-01-01 14:10'"]
  end

  def test_lesser_equal_than_string
    assert_equal @_class.parse_filter_adapter({"row.colum1" => "<= '2024-01-01 14:10'"}),
      ["row.colum1 <= ?", "'2024-01-01 14:10'"]
  end

  def test_greater_than_number
    assert_equal @_class.parse_filter_adapter({"row.colum1" => "> 202"}),
      ["row.colum1 > ?", "202"]
  end

  def test_greater_than_string
    assert_equal @_class.parse_filter_adapter({"row.colum1" => "> '2024-01-01 14:10'"}),
      ["row.colum1 > ?", "'2024-01-01 14:10'"]
  end

  def test_greater_equal_than_string
    assert_equal @_class.parse_filter_adapter({"row.colum1" => ">= '2024-01-01 14:10'"}),
      ["row.colum1 >= ?", "'2024-01-01 14:10'"]
  end

  def test_initializer_sets_time_zone
    assert_equal 'America/Sao_Paulo', JsonApiFilterAdapter.time_zone
  end

  def test_range_with_dates_hours_and_time_zone
    JsonApiFilterAdapter.time_zone = ActiveSupport::TimeZone['America/Sao_Paulo']

    result = @_class.parse_filter_adapter({
      "row.colum1" => "2024-09-10 00:00..2024-09-10 23:59"
    })

    query_between, start_date, end_date = result

    assert_equal start_date.year, 2024
    assert_equal start_date.month, 9
    assert_equal start_date.day, 10
    assert_equal start_date.hour, 0
    assert_equal start_date.min, 0
    assert_equal start_date.time_zone.utc_offset / 3600, -3

    assert_equal end_date.year, 2024
    assert_equal end_date.month, 9
    assert_equal end_date.day, 10
    assert_equal end_date.hour, 23
    assert_equal end_date.min, 59
    assert_equal end_date.time_zone.utc_offset / 3600, -3

    assert_equal query_between, "row.colum1 BETWEEN ? AND ?"
  end
end