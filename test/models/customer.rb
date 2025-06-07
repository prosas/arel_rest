class Customer < ActiveRecord::Base
  include ArelRest::Query
  
  has_many :orders
  has_many :reviews
 
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :phone, presence: true
end 