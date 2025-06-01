require "minitest/autorun"
require 'arel_rest'
require 'active_support/all'
require 'byebug'
require_relative './db_setup'
Dir[File.join(__dir__, './models', '*.rb')].sort.each do |file|
  require_relative file
end

class QueryTest < Minitest::Test
  DatabaseCleaner.clean_with(:truncation)

  def setup
    DatabaseCleaner.start
    ArelRest.time_zone = 'America/Sao_Paulo'
    
    # Create sample users for testing
    @john = User.create!(name: 'John Doe', age: 25, created_at: '2024-01-01 10:00:00')
    @jane = User.create!(name: 'Jane Smith', age: 30, created_at: '2024-01-02 11:00:00')
    @bob = User.create!(name: 'Bob Johnson', age: 25, created_at: '2024-01-03 12:00:00')
    @alice = User.create!(name: nil, age: 22, created_at: '2024-01-04 13:00:00')
  end

  def teardown
    # Clean up the database after each test
    # then, whenever you need to clean the DB
    DatabaseCleaner.clean
  end

  def test_filter_users_by_name
    filter = {
      "and" => [
        { attribute: "users.name", operator: "eq", values: "John Doe" }
      ]
    }
    result = User.filter(filter)
    
    assert_equal 1, result.count
    assert_equal @john.id, result.first.id
  end

  def test_filter_users_by_age_range
    filter = {
      "and" => [
        { attribute: "users.age", operator: "between", values: [24, 26] }
      ]
    }
    result = User.filter(filter)
    
    assert_equal 2, result.count
    assert_includes result.pluck(:name), "John Doe"
    assert_includes result.pluck(:name), "Bob Johnson"
  end

  def test_filter_users_with_complex_conditions
    filter = {
      "or" => [
        { attribute: "users.age", operator: "eq", values: 30 },
        "and" => [
          { attribute: "users.name", operator: "matches", values: "John D" },
          { attribute: "users.age", operator: "eq", values: 25 }
        ]
      ]
    }
    result = User.filter(filter)

    assert_equal 2, result.count
    assert_includes result.pluck(:name), "John Doe"
    assert_includes result.pluck(:name), "Jane Smith"
  end

  def test_filter_users_with_in_condition
    filter = {
      "and" => [
        { attribute: "users.name", operator: "in", values: ["John Doe", "Jane Smith"] }
      ]
    }
    result = User.filter(filter)
    
    assert_equal 2, result.count
    assert_includes result.pluck(:name), "John Doe"
    assert_includes result.pluck(:name), "Jane Smith"
  end

  def test_filter_users_with_not_in_condition
    filter = {
      "and" => [
        { attribute: "users.name", operator: "not_in", values: ["Bob Johnson"] }
      ]
    }
    result = User.filter(filter)
    
    assert_equal 2, result.count
    assert_includes result.pluck(:name), "John Doe"
    assert_includes result.pluck(:name), "Jane Smith"
  end

  # Equality Tests
  def test_eq_predication
    result = User.filter({
      "and" => [{ attribute: "users.name", operator: "eq", values: "John Doe" }]
    })
    assert_equal 1, result.count
    assert_equal @john.id, result.first.id
  end

  def test_not_eq_predication
    result = User.filter({
      "or" => [
        { attribute: "users.name", operator: "not_eq", values: "John Doe" },
        { attribute: "users.name", operator: "eq", values: "=null=" }
      ]
    })
    assert_equal 3, result.count
    refute_includes result.pluck(:id), @john.id
  end

  # Comparison Tests
  def test_gt_predication
    result = User.filter({
      "and" => [{ attribute: "users.age", operator: "gt", values: 25 }]
    })
    assert_equal 1, result.count
    assert_equal @jane.id, result.first.id
  end

  def test_gteq_predication
    result = User.filter({
      "and" => [{ attribute: "users.age", operator: "gteq", values: 25 }]
    })
    assert_equal 3, result.count
    assert_includes result.pluck(:id), @john.id
    assert_includes result.pluck(:id), @jane.id
    assert_includes result.pluck(:id), @bob.id
  end

  def test_lt_predication
    result = User.filter({
      "and" => [{ attribute: "users.age", operator: "lt", values: 25 }]
    })
    assert_equal 1, result.count
    assert_equal @alice.id, result.first.id
  end

  def test_lteq_predication
    result = User.filter({
      "and" => [{ attribute: "users.age", operator: "lteq", values: 25 }]
    })
    assert_equal 3, result.count
    assert_includes result.pluck(:id), @john.id
    assert_includes result.pluck(:id), @bob.id
    assert_includes result.pluck(:id), @alice.id
  end

  # Pattern Matching Tests
  def test_matches_predication
    result = User.filter({
      "and" => [{ attribute: "users.name", operator: "matches", values: "John D" }]
    })

    assert_equal 1, result.count
    assert_equal @john.id, result.first.id
  end

  def test_does_not_match_predication
    result = User.filter({
      "or" => [
        { attribute: "users.name", operator: "does_not_match", values: "John D" },
        { attribute: "users.name", operator: "eq", values: "=null=" },
      ]
    })

    assert_equal 3, result.count
    refute_includes result.pluck(:id), @john.id
  end

  # IN Tests
  def test_in_predication
    result = User.filter({
      "and" => [{ attribute: "users.name", operator: "in", values: ["John Doe", "Jane Smith"] }]
    })
    assert_equal 2, result.count
    assert_includes result.pluck(:id), @john.id
    assert_includes result.pluck(:id), @jane.id
  end

  def test_not_in_predication
    result = User.filter({
      "or" => [
        { attribute: "users.name", operator: "not_in", values: ["John Doe", "Jane Smith"] },
        { attribute: "users.name", operator: "eq", values: '=null=' }
      ]
    })

    assert_equal 2, result.count
    assert_includes result.pluck(:id), @bob.id
    assert_includes result.pluck(:id), @alice.id
  end

  # NULL Tests
  def test_is_null_predication
    result = User.filter({
      "and" => [{ attribute: "users.name", operator: "eq", values: "=null=" }]
    })
    assert_equal 1, result.count
    assert_equal @alice.id, result.first.id
  end

  def test_is_not_null_predication
    result = User.filter({
      "and" => [{ attribute: "users.name", operator: "not_eq", values: "=null=" }]
    })
    assert_equal 3, result.count
    refute_includes result.pluck(:id), @alice.id
  end

  # Between Tests
  def test_between_predication_with_numbers
    result = User.filter({
      "and" => [{ attribute: "users.age", operator: "between", values: [24, 26] }]
    })
    assert_equal 2, result.count
    assert_includes result.pluck(:id), @john.id
    assert_includes result.pluck(:id), @bob.id
  end

  def test_between_predication_with_dates
    result = User.filter({
      "and" => [{ 
        attribute: "users.created_at", 
        operator: "between", 
        values: ["2024-01-01 00:00:00", "2024-01-02 23:59:59"] 
      }]
    })
    assert_equal 2, result.count
    assert_includes result.pluck(:id), @john.id
    assert_includes result.pluck(:id), @jane.id
  end

  # Complex Combinations
  def test_complex_and_or_combinations
    result = User.filter({
      "or" => [
        { attribute: "users.age", operator: "eq", values: 30 },
        "and" => [
          { attribute: "users.name", operator: "matches", values: "John" },
          { attribute: "users.created_at", operator: "lt", values: "2024-01-02 00:00:00" }
        ]
      ]
    })
    assert_equal 2, result.count
    assert_includes result.pluck(:id), @john.id
    assert_includes result.pluck(:id), @jane.id
  end

  def test_multiple_and_conditions
    result = User.filter({
      "and" => [
        { attribute: "users.age", operator: "gteq", values: 25 },
        { attribute: "users.created_at", operator: "lt", values: "2024-01-03 00:00:00" },
        { attribute: "users.name", operator: "not_eq", values: "=null=" }
      ]
    })
    assert_equal 2, result.count
    assert_includes result.pluck(:id), @john.id
    assert_includes result.pluck(:id), @jane.id
  end

  def test_nested_or_conditions
    result = User.filter({
      "and" => [
        { attribute: "users.age", operator: "lteq", values: 25 },
        "or" => [
          { attribute: "users.name", operator: "matches", values: "John D" },
          { attribute: "users.name", operator: "eq", values: "=null=" }
        ]
      ]
    })

    assert_equal 2, result.count
    assert_includes result.pluck(:id), @john.id
    assert_includes result.pluck(:id), @alice.id
  end
end