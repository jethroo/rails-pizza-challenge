class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  validates :uid, presence: true,  uniqueness: true

  scope :open, -> { where(completed_at: nil) }

  def discount_code_multiplier
    code = Rails.configuration.orders[:discounts][discount_code&.to_sym]
    return 0 unless code

    BigDecimal(code.fetch(:deduction_in_percent, 0).to_s) / 100.0
  end

  def promotions
    promotion_codes.filter_map do |code|
      Rails.configuration.orders[:promotions][code&.to_sym]
    end
  end
end
