# Arel Rest

Provides a simple REST API interface for dynamically constructing SQL queries using ActiveRecord. Expose powerful query capabilities to client applications while maintaining full control over query logic and security.

## Requirements

- Ruby 2.7 or higher
- ActiveRecord
- `require 'time'` (necessary for date and time manipulation)

## Installation

1. **Add the gem to your project:**

Run the following command to add the gem to your `Gemfile`:

```bash
bundle install arel_rest
```

2. **Add the module to your model and define schema:**

The `ArelRest::Query` module provides JSON interfaces to your ActiveRecord models. When included, it automatically adds the `query` class method to your model, allowing you to build complex database queries using JSON objects.

### Including the Module

```ruby
class Product < ActiveRecord::Base
  include ArelRest::Query
  
  # Your existing ActiveRecord associations
  belongs_to :category
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :reviews
end
```

### Defining the Schema

The schema is the core configuration that tells ArelRest which relationships can be used in queries. It defines the navigation paths between your models, enabling complex joins and cross-table filtering.

```ruby
class Product < ActiveRecord::Base
  include ArelRest::Query
  
  schema do
    {
      'Product': {
        category: {
          'Category': {}
        },
        orders: {
          "Order": {
            customer: {
              'Customer': {}
            }
          }
        },
        reviews: {
          'Review': {
            customer: {
              'Customer': {}
            }
          }
        }
      }
    }
  end
end
```

### How the Schema Works

The schema is a nested hash structure that maps your model relationships:

- **Top level key**: The current model class name (Ex: `'Product'`)
- **Nested keys**: Association names from your ActiveRecord model (Exs: `category`, `orders`, `reviews`)
- **Values**: Nested hashes representing the target model and its relationships

#### Schema Structure Explained:

```ruby
{
  '<CURRENT_MODEL_CLASS>': {
    '<ASSOCIATION_NAME>': {
      '<TARGET_MODEL_CLASS>': {
        # Further nested relationships...
      }
    }
  }
}
```

#### Examples of Different Schema Configurations:

**Simple One-to-Many Relationship:**
```ruby
class Category < ActiveRecord::Base
  include ArelRest::Query
  
  schema do
    {
      'Category': {
        products: {
          'Product': {}
        }
      }
    }
  end
  
  has_many :products
end
```

**Complex Nested Relationships:**
```ruby
class Order < ActiveRecord::Base
  include ArelRest::Query
  
  schema do
    {
      'Order': {
        customer: {
          'Customer': {}
        },
        order_items: {
          'OrderItem': {
            product: {
              'Product': {
                category: {
                  'Category': {}
                }
              }
            }
          }
        }
      }
    }
  end
  
  belongs_to :customer
  has_many :order_items
  has_many :products, through: :order_items
end
```

**Self-Referential Relationship:**
```ruby
class Employee < ActiveRecord::Base
  include ArelRest::Query
  
  schema do
    {
      'Employee': {
        manager: {
          'Employee': {}
        },
        subordinates: {
          'Employee': {}
        }
      }
    }
  end
  
  belongs_to :manager, class_name: 'Employee', optional: true
  has_many :subordinates, class_name: 'Employee', foreign_key: 'manager_id'
end
```

3. **Example to use the method that will process the query:**

### Query Object Format

The ArelRest query object is a JSON structure that allows you to build database queries dynamically. The object supports the following properties:

#### Available Properties:

- **`filters`**: JSON object defining WHERE conditions
- **`sort`**: JSON object defining ORDER BY clauses  
- **`dimensions`**: Array of strings defining GROUP BY columns
- **`measures`**: String defining aggregation function (count, sum, average, minimum, maximum)
- **`page`**: Integer for pagination (default: 0)
- **`size`**: Integer for page size (default: 100)
- **`timezone`**: String for timezone configuration

#### Basic Query Structure:

```json
{
  "filters": { /* filter conditions */ },
  "sort": { /* sorting conditions */ },
  "dimensions": ["column1", "table.column2"],
  "measures": "function.column",
  "page": 0,
  "size": 100,
  "timezone": "America/Sao_Paulo"
}
```

#### Examples:

**1. Simple Filter Query:**
```json
{
  "filters": {
    "and": [
      {"attribute": "products.name", "operator": "eq", "values": "Smartphone X"},
      {"attribute": "products.price", "operator": "lt", "values": 1000}
    ]
  }
}
```

```ruby
# Using the query method
result = Product.query({
  filters: {
    and: [
      { attribute: "products.name", operator: "eq", values: "Smartphone X" },
      { attribute: "products.price", operator: "lt", values: 1000 }
    ]
  }
})
```

**2. Complex Filter with OR Conditions:**
```json
{
  "filters": {
    "or": [
      {"attribute": "categories.name", "operator": "eq", "values": "Electronics"},
      {"attribute": "products.price", "operator": "gt", "values": 2000}
    ]
  }
}
```

```ruby
# Using the query method
result = Product.query({
  filters: {
    or: [
      { attribute: "categories.name", operator: "eq", values: "Electronics" },
      { attribute: "products.price", operator: "gt", values: 2000 }
    ]
  }
})
```

**3. Aggregation Query with Grouping:**
```json
{
  "measures": "sum.price",
  "dimensions": ["products.category_id", "categories.name"],
  "filters": {
    "and": [
      {"attribute": "products.stock", "operator": "gt", "values": 49}
    ]
  },
  "sort": {"categories.id": "asc"},
  "size": 100,
  "page": 0
}
```

```ruby
# Using the query method
result = Product.query({
  measures: "sum.price",
  dimensions: ["products.category_id", "categories.name"],
  filters: {
    and: [
      { attribute: "products.stock", operator: "gt", values: 49 }
    ]
  },
  sort: { "categories.id": "asc" },
  size: 100,
  page: 0
})
```

**4. Count Query with Date Grouping:**
```json
{
  "measures": "count.id",
  "dimensions": ["products.created_month", "products.created_year"],
  "sort": {"products.created_year": "asc", "products.created_month": "asc"}
}
```

```ruby
# Using the query method
result = Product.query({
  measures: "count.id",
  dimensions: ["products.created_month", "products.created_year"],
  sort: { "products.created_year": "asc", "products.created_month": "asc" }
})
```

**5. Average Query:**
```json
{
  "measures": "average.price",
  "dimensions": ["products.created_year"],
  "sort": {"products.created_year": "asc"}
}
```

```ruby
# Using the query method
result = Product.query({
  measures: "average.price",
  dimensions: ["products.created_year"],
  sort: { "products.created_year": "asc" }
})
```

**6. Complex Nested Conditions:**
```json
{
  "filters": {
    "or": [
      {"attribute": "users.age", "operator": "eq", "values": 30},
      {
        "and": [
          {"attribute": "users.name", "operator": "matches", "values": "John D"},
          {"attribute": "users.age", "operator": "eq", "values": 25}
        ]
      }
    ]
  }
}
```

```ruby
# Using the query method
result = User.query({
  filters: {
    or: [
      { attribute: "users.age", operator: "eq", values: 30 },
      {
        and: [
          { attribute: "users.name", operator: "matches", values: "John D" },
          { attribute: "users.age", operator: "eq", values: 25 }
        ]
      }
    ]
  }
})
```

**7. Complete Query with All Features:**
```ruby
# Example of a complete query using all available features
result = Product.query({
  filters: {
    and: [
      { attribute: "categories.name", operator: "eq", values: "Electronics" },
      { attribute: "products.price", operator: "between", values: [500, 1500] }
    ]
  },
  measures: "sum.price",
  dimensions: ["products.category_id", "categories.name"],
  sort: { "categories.name": "asc", "products.price": "desc" },
  page: 0,
  size: 50,
  timezone: "America/Sao_Paulo"
})
```

#### Supported Operators:

- **Equality**: `eq`, `not_eq`
- **Comparison**: `gt`, `gteq`, `lt`, `lteq`
- **Pattern Matching**: `matches`, `does_not_match`
- **Set Operations**: `in`, `not_in`
- **Null Checks**: `is_null`, `is_not_null`
- **Range**: `between`

#### Supported Aggregation Functions:

- **`count.column`**: Count records
- **`sum.column`**: Sum values
- **`average.column`**: Calculate average
- **`minimum.column`**: Find minimum value
- **`maximum.column`**: Find maximum value

## Configuring Time Zone for JsonApiFilterAdapter

To use the `time_zone` feature correctly after installing the gem, you need to create an initializer file and add the following configuration:

```ruby
# config/initializers/json_api_filter_adapter.rb

# Sets the gem's timezone based on the Time.zone configured by the application
Rails.application.config.after_initialize do
  JsonApiFilterAdapter.time_zone = ActiveSupport::TimeZone['America/Sao_Paulo']
end
```

## About date filters and the use of `Time.use_zone` in the Code

### `Time.use_zone(JsonApiFilterAdapter.time_zone) { }`:
- **Purpose**: Temporarily changes the time zone to execute the code inside the block, using the configured time zone (`JsonApiFilterAdapter.time_zone`), ignoring the default time zone.
- **Context**:
- This is useful to ensure that date and time operations inside the block are interpreted in the configured time zone, without affecting the rest of the application.

### Block in the code:
- **Checks and converts date ranges**:
- **Case with date**: If the value is just a date (`YYYY-MM-DD`), converts the range to the start and end of the day, respecting the configured time zone. - **Case with date and time**: If the value contains a date and time (`YYYY-MM-DD HH:MM..YYYY-MM-DD HH:MM`), process the interval according to the time, keeping the configured time zone.
- **Case with explicit time zone**: If the value contains a date, time and an explicit time zone, the code processes the interval without modifying the explicit time zone.

- **Ensures consistency**:
- `Time.use_zone` ensures that all date and time values ​​are converted and handled in the correct time zone (`JsonApiFilterAdapter.time_zone`), regardless of the system's default time zone.

## How to test

```
rake test
```