class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  validates :uid, presence: true,  uniqueness: true
end
