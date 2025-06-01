class Category < ActiveRecord::Base
  include ArelRest::Query
  
  has_many :products
  
  validates :name, presence: true, uniqueness: true
end 