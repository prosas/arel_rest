class Order < ActiveRecord::Base
  include ArelRest::Query
  
  belongs_to :customer
  has_many :order_items
  has_many :products, through: :order_items
  
  validates :customer, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing shipped delivered cancelled] }
end 