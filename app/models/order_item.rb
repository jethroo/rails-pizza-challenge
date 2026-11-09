class OrderItem < ApplicationRecord
  belongs_to :order

  enum :size, { small: 0, medium: 1, large: 2 }
end
