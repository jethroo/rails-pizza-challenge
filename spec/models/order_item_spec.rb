require "rails_helper"

RSpec.describe OrderItem, type: :model do
  let(:pricing_config) do
    {
      size_multipliers: {
        Small: 0.7,
        Medium: 1.0,
        Large: 1.3
      },
      pizzas: {
        Margherita: 10.0,
        Salami: 12.0
      },
      ingredients: {
        Cheese: 2.0,
        Mushrooms: 1.5
      }
    }
  end

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

  describe "#price" do
    before do
      allow(Rails.configuration).to receive(:orders)
        .and_return(pricing_config)
    end

    it "calculates the base price for a medium pizza" do
      item = OrderItem.new(
        name: "Margherita",
        size: :medium,
        extra_ingredients: []
      )

      expect(item.price).to eq(BigDecimal("10.0"))
    end

    it "applies the size multiplier to the base price" do
      item = OrderItem.new(
        name: "Salami",
        size: :large,
        extra_ingredients: []
      )

      expect(item.price).to eq(BigDecimal("15.6"))
    end

    it "includes extra ingredients in the total price" do
      item = OrderItem.new(
        name: "Margherita",
        size: :medium,
        extra_ingredients: [ "Cheese", "Mushrooms" ]
      )

      expect(item.price).to eq(BigDecimal("13.5"))
    end

    it "applies the size multiplier to extra ingredients" do
      item = OrderItem.new(
        name: "Margherita",
        size: :small,
        extra_ingredients: [ "Cheese" ]
      )

      # (10.0 + 2.0) * 0.7 = 8.4
      expect(item.price).to eq(BigDecimal("8.4"))
    end

    it "raises an error for an unknown pizza" do
      item = OrderItem.new(
        name: "Unknown",
        size: :medium,
        extra_ingredients: []
      )

      expect { item.price }.to raise_error(KeyError)
    end

    it "raises an error for an unknown ingredient" do
      item = OrderItem.new(
        name: "Margherita",
        size: :medium,
        extra_ingredients: [ "Unknown" ]
      )

      expect { item.price }.to raise_error(KeyError)
    end
  end

  describe "#extra_ingredients_price" do
    before do
      allow(Rails.configuration).to receive(:orders)
        .and_return(pricing_config)
    end

    it "returns zero when no extra ingredients are present" do
      item = OrderItem.new(
        size: :medium,
        extra_ingredients: []
      )

      expect(item.extra_ingredients_price).to eq(BigDecimal("0"))
    end

    it "sums the prices of all extra ingredients" do
      item = OrderItem.new(
        size: :medium,
        extra_ingredients: [ "Cheese", "Mushrooms" ]
      )

      expect(item.extra_ingredients_price).to eq(BigDecimal("3.5"))
    end

    it "counts duplicate ingredients separately" do
      item = OrderItem.new(
        size: :medium,
        extra_ingredients: [ "Cheese", "Cheese" ]
      )

      expect(item.extra_ingredients_price).to eq(BigDecimal("4.0"))
    end

    it "applies the size multiplier" do
      item = OrderItem.new(
        size: :large,
        extra_ingredients: [ "Cheese" ]
      )

      expect(item.extra_ingredients_price).to eq(BigDecimal("2.6"))
    end
  end
end
