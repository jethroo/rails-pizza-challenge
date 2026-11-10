class OrderItem < ApplicationRecord
  belongs_to :order

  enum :size, { small: 0, medium: 1, large: 2 }

  def price
    item_price + extra_ingredients_price
  end

  def extra_ingredients_price
    extra_ingredients.sum(0) { |extra| ingredient_price(extra) } * size_multiplier
  end

  private

  def size_multiplier
    BigDecimal(Rails.configuration.orders[:size_multipliers].fetch(size.capitalize.to_sym).to_s)
  end

  def item_price
    BigDecimal(Rails.configuration.orders[:pizzas].fetch(name.to_sym).to_s) * size_multiplier
  end

  def ingredient_price(ingredient_name)
    BigDecimal(Rails.configuration.orders[:ingredients].fetch(ingredient_name.to_sym).to_s)
  end
end
