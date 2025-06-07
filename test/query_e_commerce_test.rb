require "minitest/autorun"
require 'arel_rest'
require 'active_support/all'
require 'byebug'
require_relative './db_setup'
Dir[File.join(__dir__, './models', '*.rb')].sort.each do |file|
  require_relative file
end

class QueryECommerceTest < Minitest::Test
  DatabaseCleaner.clean_with(:truncation)

  def setup
    DatabaseCleaner.start
    ArelRest.time_zone = 'America/Sao_Paulo'
    # Create categories
    @electronics = Category.create!(name: 'Electronics', description: 'Electronic devices and gadgets')
    @books = Category.create!(name: 'Books', description: 'Physical and digital books')
    @clothing = Category.create!(name: 'Clothing', description: 'Fashion items')

    # Create products
    @smartphone = Product.create!(
      name: 'Smartphone X',
      description: 'Latest smartphone model',
      price: 999.99,
      stock: 50,
      category: @electronics,
      created_date: Date.new(2024, 1, 10),
      created_month: 1,
      created_year: 2024
    )

    @laptop = Product.create!(
      name: 'Laptop Pro',
      description: 'Professional laptop',
      price: 1499.99,
      stock: 30,
      category: @electronics,
      created_date: Date.new(2024, 2, 15),
      created_month: 2,
      created_year: 2024
    )

    @ruby_book = Product.create!(
      name: 'Ruby Programming',
      description: 'Learn Ruby programming',
      price: 49.99,
      stock: 100,
      category: @books,
      created_date: Date.new(2024, 1, 20),
      created_month: 1,
      created_year: 2024
    )

    @tshirt = Product.create!(
      name: 'Cotton T-Shirt',
      description: 'Comfortable cotton t-shirt',
      price: 19.99,
      stock: 200,
      category: @clothing,
      created_date: Date.new(2024, 3, 5),
      created_month: 3,
      created_year: 2024
    )

    # Create customers
    @john = Customer.create!(
      name: 'John Doe',
      email: 'john@example.com',
      phone: '123-456-7890',
      address: '123 Main St, City'
    )

    @jane = Customer.create!(
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '098-765-4321',
      address: '456 Oak St, Town'
    )

    # Create orders
    @order1 = Order.create!(
      customer: @john,
      status: 'pending',
      shipping_address: '123 Main St, City',
      created_date: Date.new(2024, 1, 11),
      created_month: 1,
      created_year: 2024
    )

    @order2 = Order.create!(
      customer: @jane,
      status: 'delivered',
      shipping_address: '456 Oak St, Town',
      created_date: Date.new(2024, 2, 16),
      created_month: 2,
      created_year: 2024
    )

    # Create order items
    OrderItem.create!(
      order: @order1,
      product: @smartphone,
      quantity: 1,
      unit_price: @smartphone.price,
      created_date: Date.new(2024, 1, 11),
      created_month: 1,
      created_year: 2024
    )

    OrderItem.create!(
      order: @order1,
      product: @ruby_book,
      quantity: 2,
      unit_price: @ruby_book.price,
      created_date: Date.new(2024, 1, 11),
      created_month: 1,
      created_year: 2024
    )

    OrderItem.create!(
      order: @order2,
      product: @laptop,
      quantity: 1,
      unit_price: @laptop.price,
      created_date: Date.new(2024, 2, 16),
      created_month: 2,
      created_year: 2024
    )

    # Create reviews
    Review.create!(
      product: @smartphone,
      customer: @john,
      rating: 5,
      comment: 'Great smartphone! Very satisfied.'
    )

    Review.create!(
      product: @ruby_book,
      customer: @jane,
      rating: 4,
      comment: 'Good book for learning Ruby.'
    )

    Review.create!(
      product: @laptop,
      customer: @jane,
      rating: 5,
      comment: 'Excellent laptop for work!'
    )
  end

  def teardown
    # Clean up the database after each test
    # then, whenever you need to clean the DB
    DatabaseCleaner.clean
  end

  def test_filter_production
    filter = {
      "and" => [
        { attribute: "categories.name", operator: "eq", values: "Electronics" },
        { attribute: "products.price", operator: "lt", values: 2000.0 },
        { attribute: "customers.name", operator: "matches", values: "Jane" }
      ]
    }

    assert_equal 1, Product.filter(filter).count
  end

  def test_sum_metric
    arel_rest_query = {
      "measures": "sum.price",
      "dimensions": ["category_id", "categories.name"],
      "filters": {
        "and" => [
          { attribute: "products.stock", operator: "gt", values: 49 }
        ]
      },
      "limit": 100,
      "offset": 0,
      "order": {
        "categories.id": "asc"
      },
      "timezone": "America/Los_Angeles"
    }

    assert_equal({[1, "Electronics"] => 999.99, [2, "Books"] => 49.99, [3, "Clothing"] => 19.99}, Product.query(arel_rest_query))
  end

  def test_count_products_by_month
    query = {
      "measures": "count.id",
      "dimensions": ["created_month", "created_year"],
      "order": {"created_year": "asc", "created_month": "asc"}
    }
    result = Product.query(query)
    assert_equal({[1, 2024] => 2, [2, 2024] => 1, [3, 2024] => 1}, result)
  end

  def test_average_price_by_year
    query = {
      "measures": "average.price",
      "dimensions": ["created_year"],
      "order": {"created_year": "asc"}
    }
    result = Product.query(query)
    expected_avg = (999.99 + 1499.99 + 49.99 + 19.99) / 4.0
    assert_in_delta expected_avg, result[2024], 0.01
  end

  def test_minimum_price_by_month
    query = {
      "measures": "minimum.price",
      "dimensions": ["created_month", "created_year"],
      "order": {"created_year": "asc", "created_month": "asc"}
    }
    result = Product.query(query)
    assert_equal 49.99, result[[1, 2024]]
    assert_equal 1499.99, result[[2, 2024]]
    assert_equal 19.99, result[[3, 2024]]
  end

  def test_maximum_price_by_month
    query = {
      "measures": "maximum.price",
      "dimensions": ["created_month", "created_year"],
      "order": {"created_year": "asc", "created_month": "asc"}
    }

    result = Product.query(query)
    assert_equal 999.99, result[[1, 2024]]
    assert_equal 1499.99, result[[2, 2024]]
    assert_equal 19.99, result[[3, 2024]]
  end

  def test_sum_price_by_month
    query = {
      "measures": "sum.price",
      "dimensions": ["created_month", "created_year"],
      "order": {"created_year": "asc", "created_month": "asc"}
    }
    result = Product.query(query)
    assert_equal 1049.98, result[[1, 2024]] # 999.99 + 49.99
    assert_equal 1499.99, result[[2, 2024]]
    assert_equal 19.99, result[[3, 2024]]
  end

  def test_count_orders_by_year
    query = {
      "measures": "count.id",
      "dimensions": ["created_year"]
    }
    result = Order.query(query)
    assert_equal({2024 => 2}, result)
  end

  def test_average_order_items_by_month
    query = {
      "measures": "average.quantity",
      "dimensions": ["created_month", "created_year"]
    }
    result = OrderItem.query(query)
    assert_in_delta 1.5, result[[1, 2024]], 0.01 # (1+2)/2
    assert_in_delta 1.0, result[[2, 2024]], 0.01
  end

  def test_minimum_order_item_quantity_by_year
    query = {
      "measures": "minimum.quantity",
      "dimensions": ["created_year"]
    }
    result = OrderItem.query(query)
    assert_equal 1, result[2024]
  end

  def test_maximum_order_item_quantity_by_year
    query = {
      "measures": "maximum.quantity",
      "dimensions": ["created_year"]
    }
    result = OrderItem.query(query)
    assert_equal 2, result[2024]
  end

  def test_sum_order_item_quantity_by_month
    query = {
      "measures": "sum.quantity",
      "dimensions": ["created_month", "created_year"]
    }
    result = OrderItem.query(query)
    assert_equal 3, result[[1, 2024]] # 1+2
    assert_equal 1, result[[2, 2024]]
  end
end