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
      category: @electronics
    )

    @laptop = Product.create!(
      name: 'Laptop Pro',
      description: 'Professional laptop',
      price: 1499.99,
      stock: 30,
      category: @electronics
    )

    @ruby_book = Product.create!(
      name: 'Ruby Programming',
      description: 'Learn Ruby programming',
      price: 49.99,
      stock: 100,
      category: @books
    )

    @tshirt = Product.create!(
      name: 'Cotton T-Shirt',
      description: 'Comfortable cotton t-shirt',
      price: 19.99,
      stock: 200,
      category: @clothing
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
      shipping_address: '123 Main St, City'
    )

    @order2 = Order.create!(
      customer: @jane,
      status: 'delivered',
      shipping_address: '456 Oak St, Town'
    )

    # Create order items
    OrderItem.create!(
      order: @order1,
      product: @smartphone,
      quantity: 1,
      unit_price: @smartphone.price
    )

    OrderItem.create!(
      order: @order1,
      product: @ruby_book,
      quantity: 2,
      unit_price: @ruby_book.price
    )

    OrderItem.create!(
      order: @order2,
      product: @laptop,
      quantity: 1,
      unit_price: @laptop.price
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

  def test_count_metric
    arel_rest_query = {
      "measures": "count",
      "dimensions": ["category_id", "categories.name"],
      "filters": {
        "and" => [
          { attribute: "products.stock", operator: "gt", values: 49 }
        ]
      },
      # "timeDimensions": [
      #   {
      #     "dimension": "stories.time",
      #     "dateRange": ["2015-01-01", "2015-12-31"],
      #     "granularity": "month"
      #   }
      # ],
      # "limit": 100,
      # "offset": 50,
      "order": {
        "categories.id": "asc"
      },
      "timezone": "America/Los_Angeles"
    }
    # debugger
    assert_equal 4, Product.query(arel_rest_query)
  end

  # def test_order_queries
  #   # Test order status queries
  #   assert_equal 1, Order.where(status: 'pending').count
  #   assert_equal 1, Order.where(status: 'delivered').count

  #   # Test customer orders
  #   assert_equal 1, @john.orders.count
  #   assert_equal 1, @jane.orders.count
  # end

  # def test_review_queries
  #   # Test product reviews
  #   assert_equal 1, @smartphone.reviews.count
  #   assert_equal 1, @ruby_book.reviews.count

  #   # Test customer reviews
  #   assert_equal 1, @john.reviews.count
  #   assert_equal 2, @jane.reviews.count

  #   # Test high rated products
  #   high_rated = Review.where('rating >= ?', 5)
  #   assert_equal 2, high_rated.count
  # end

  # def test_category_queries
  #   # Test products by category
  #   assert_equal 2, @electronics.products.count
  #   assert_equal 1, @books.products.count
  #   assert_equal 1, @clothing.products.count
  # end

  # def test_complex_queries
  #   # Find all products ordered by John
  #   johns_products = Product.joins(order_items: :order)
  #                         .where(orders: { customer_id: @john.id })
  #                         .distinct
  #   assert_equal 2, johns_products.count

  #   # Find all customers who bought electronics
  #   electronics_customers = Customer.joins(orders: { order_items: { product: :category }})
  #                                .where(categories: { id: @electronics.id })
  #                                .distinct
  #   assert_equal 2, electronics_customers.count

  #   # Find average rating for electronics products
  #   electronics_avg_rating = Review.joins(product: :category)
  #                                .where(categories: { id: @electronics.id })
  #                                .average(:rating)
  #   assert_equal 5.0, electronics_avg_rating
  # end
end