require "rails_helper"

RSpec.describe OrderItem, type: :model do
  describe "associations" do
    it "requires an order" do
      order_item = OrderItem.new(order: nil)

      expect(order_item).not_to be_valid
      expect(order_item.errors[:order]).to include("must exist")
    end

    it "belongs to an order" do
      order = Order.create!(uid: SecureRandom.uuid)
      order_item = OrderItem.new(order: order)

      expect(order_item.order).to eq(order)
    end
  end

  describe "size enum" do
    it "defines the correct size mappings" do
      expect(described_class.sizes).to eq(
        "small" => 0,
        "medium" => 1,
        "large" => 2
      )
    end

    it "supports assigning sizes" do
      order_item = OrderItem.new(size: :medium)

      expect(order_item.size).to eq("medium")
      expect(order_item).to be_medium
    end

    it "rejects invalid sizes" do
      expect {
        OrderItem.new(size: :extraLarge)
      }.to raise_error(ArgumentError)
    end
  end
end
