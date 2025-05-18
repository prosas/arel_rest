require 'active_record'
require 'sqlite3'
require 'logger'

# Enable logging (optional, helpful for debugging)
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Establish SQLite connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Example schema definition (for testing)
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.integer :age
    t.timestamps
  end
end
# Example model
class User < ActiveRecord::Base; end
