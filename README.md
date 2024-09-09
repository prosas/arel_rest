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