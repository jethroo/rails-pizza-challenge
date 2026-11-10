require 'json'

size_map = {
  "Small" => 0,
  "Medium" => 1,
  "Large" => 2
}

JSON.parse(File.read("./data/orders.json")).each do |order|
  ActiveRecord::Base.transaction do
    create_order = Order.create!(
      uid: order['id'],
      created_at: order['createdAt'],
      promotion_codes: order['promotionCodes'],
      discount_code: order['discountCode']
    )

    order['items'].each do |order_item|
      create_order.order_items.create!(
        name: order_item['name'],
        size: size_map[order_item['size']],
        extra_ingredients: order_item['add'],
        omitted_ingredients: order_item['remove']
      )
    end
  end
end;nil
