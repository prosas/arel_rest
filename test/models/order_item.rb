class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  
  validates :order, presence: true
  validates :product, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation :set_unit_price, on: :create
  
  scope :by_product, ->(product_id) { where(product_id: product_id) }
  scope :by_order, ->(order_id) { where(order_id: order_id) }
  
  def subtotal
    quantity * unit_price
  end
  
  private
  
  def set_unit_price
    self.unit_price = product.price if product && unit_price.nil?
  end
end 