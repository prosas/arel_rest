class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :order_items
  has_many :products, through: :order_items
  
  validates :customer, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing shipped delivered cancelled] }
end 