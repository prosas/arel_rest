require "minitest/autorun"
require 'json_api_active_record_query_adapter'
require 'byebug'
class JsonApiFilterAdapterTest < Minitest::Test
  class TestClass
    include JsonApiFilterAdapter
  end

  def setup
    @_class = TestClass.new
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

  def test_greater_than_number
    assert_equal @_class.parse_filter_adapter({"row.colum1" => "> 202"}) ,
      ["row.colum1 > ?", "202"]
  end

  def test_greater_than_string
    assert_equal @_class.parse_filter_adapter({"row.colum1" => "> '2024-01-01 14:10'"}),
      ["row.colum1 > ?", "'2024-01-01 14:10'"]
  end
end