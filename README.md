# JSON API Active Record Query Adapter

This project provides an adapter to transform filters from an API in JSON-API format into ActiveRecord-compatible SQL queries. It is useful for handling complex filters such as date ranges, comparisons, logical operators, and `LIKE` queries.

## Requirements

- Ruby 2.7 or higher
- ActiveRecord (if integrated with a database)
- `require 'time'` (necessary for date and time manipulation)

## Installation

1. **Add the gem to your project:**

   Run the following command to add the gem to your `Gemfile`:

   ```bash
   bundle add json_api_active_record_query_adapter

2. **Add the module to your controller:**

```
  include JsonApiFilterAdapter
```

3. **Example to use the method that will process the data in the controller:**

```
def index
  filter = parse_filter_adapter(params)
  @records = Model.where(filter)
  render json: @records
end
```

## How to test

```
rake test
```