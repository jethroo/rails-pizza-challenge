class OrderPricingService
  attr_reader :order, :order_total

  PriceComponent = Data.define(:name, :amount, :size, :extras)

  def initialize(order)
    @order = order
    @order_total = []
  end

  def call
    apply_item_prices
    apply_promotions
    apply_discount

    # order_total_sum.round(2)
    order_total_sum.round(2, BigDecimal::ROUND_HALF_UP)
  end

  private

  def order_total_sum
    order_total.sum(&:amount)
  end

  def apply_item_prices
    order.order_items.each do |item|
      order_total << PriceComponent.new(item.name, item.price, item.size, item.extra_ingredients_price)
    end
  end

  def apply_promotions
    order.promotions.each do |promotion_config|
      apply_promotion(promotion_config)
    end
  end

  def apply_promotion(promotion_config)
     promotion_canditates = order_total.select do |component|
       component.name == promotion_config[:target] && component.size == promotion_config[:target_size].downcase
     end

     promotion_canditates.each_slice(promotion_config[:from]) do |slice|
       next unless slice.count == promotion_config[:from]

       (1..promotion_config[:to]).each do |count|
         canditate = slice[count-1]
         order_total << PriceComponent.new(
           canditate.name, canditate.amount * -1.0 + canditate.extras,
           canditate.size, 0
         )
       end
     end
  end

  def apply_discount
    order_total << PriceComponent.new(
      "Discount",
      order_total_sum * order.discount_code_multiplier * -1,
      nil,
      0
    )
  end
end
