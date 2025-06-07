require 'active_record'
require 'sqlite3'
require 'logger'
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :transaction

# Enable logging (optional, helpful for debugging)
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Configure the database connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Create the database schema
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.integer :age
    t.timestamps
  end

  create_table :categories do |t|
    t.string :name, null: false
    t.text :description
    t.timestamps
  end
  add_index :categories, :name, unique: true

  create_table :products do |t|
    t.string :name, null: false
    t.text :description
    t.decimal :price, precision: 10, scale: 2, null: false
    t.integer :stock, null: false, default: 0
    t.references :category, foreign_key: true
    t.date :created_date
    t.integer :created_month
    t.integer :created_year
    t.timestamps
  end
  add_index :products, :name

  create_table :customers do |t|
    t.string :name, null: false
    t.string :email, null: false
    t.string :phone, null: false
    t.text :address
    t.timestamps
  end
  add_index :customers, :email, unique: true

  create_table :orders do |t|
    t.references :customer, null: false, foreign_key: true
    t.string :status, null: false, default: 'pending'
    t.decimal :total_amount, precision: 10, scale: 2
    t.text :shipping_address
    t.date :created_date
    t.integer :created_month
    t.integer :created_year
    t.timestamps
  end
  add_index :orders, :status

  create_table :order_items do |t|
    t.references :order, null: false, foreign_key: true
    t.references :product, null: false, foreign_key: true
    t.integer :quantity, null: false
    t.decimal :unit_price, precision: 10, scale: 2, null: false
    t.date :created_date
    t.integer :created_month
    t.integer :created_year
    t.timestamps
  end

  create_table :reviews do |t|
    t.references :product, null: false, foreign_key: true
    t.references :customer, null: false, foreign_key: true
    t.integer :rating, null: false
    t.text :comment, null: false
    t.timestamps
  end
  add_index :reviews, [:product_id, :customer_id], unique: true
end
