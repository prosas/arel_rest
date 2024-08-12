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
		assert_equal @_class.parse_filter_adapter({"row.colum1" => 20, "row.colum2" => ["=null="]}),["row.colum1 = ? AND row.colum2 IN (?) ", "20", [nil]]
		
		assert_equal @_class.parse_filter_adapter({"row.colum1" => 20, "row.colum2" => "=null="}),["row.colum1 = ? AND row.colum2 IS NULL ", "20"]
	end
end