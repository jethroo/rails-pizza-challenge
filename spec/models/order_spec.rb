
require "rails_helper"

RSpec.describe Order, type: :model do
  describe "associations" do
    it "destroys associated order items when deleted" do
      order = Order.create!(uid: SecureRandom.uuid)
      order.order_items.create!(name: "Margherita", size: 0)

      expect { order.destroy! }
        .to change(OrderItem, :count).by(-1)
    end
  end

  describe "validations" do
    it "requires a uid" do
      order = Order.new(uid: nil)

      expect(order).not_to be_valid
      expect(order.errors[:uid]).to include("can't be blank")
    end

    it "requires a unique uid" do
      uid = SecureRandom.uuid
      Order.create!(uid: uid)

      duplicate = Order.new(uid: uid)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:uid]).to include("has already been taken")
    end

    it "accepts a valid uid" do
      order = Order.new(uid: SecureRandom.uuid)

      expect(order).to be_valid
    end
  end

  describe "#discount_code_multiplier" do
    let(:discounts) do
      {
        SAVE10: { deduction_in_percent: 10 },
        SAVE25: { deduction_in_percent: 25 },
        NO_PERCENTAGE: {}
      }
    end

    before do
      allow(Rails.configuration).to receive(:orders)
        .and_return(discounts: discounts)
    end

    it "returns the discount as a multiplier" do
      order = Order.new(discount_code: "SAVE25")

      expect(order.discount_code_multiplier).to eq(0.25)
    end

    it "returns zero when no discount code is provided" do
      order = Order.new(discount_code: nil)

      expect(order.discount_code_multiplier).to eq(0)
    end

    it "returns zero for an unknown discount code" do
      order = Order.new(discount_code: "INVALID")

      expect(order.discount_code_multiplier).to eq(0)
    end

    it "returns zero when the percentage is missing" do
      order = Order.new(discount_code: "NO_PERCENTAGE")

      expect(order.discount_code_multiplier).to eq(0)
    end
  end

  describe "#promotions" do
    let(:promotions) do
      {
        FREE_PIZZA: { type: :free_pizza },
        TWO_FOR_ONE: { type: :two_for_one }
      }
    end

    before do
      allow(Rails.configuration).to receive(:orders)
        .and_return(promotions: promotions)
    end

    it "returns the configuration for a valid promotion" do
      order = Order.new(promotion_codes: [ "FREE_PIZZA" ])

      expect(order.promotions).to eq([
        { type: :free_pizza }
      ])
    end

    it "returns multiple valid promotions" do
      order = Order.new(
        promotion_codes: [ "FREE_PIZZA", "TWO_FOR_ONE" ]
      )

      expect(order.promotions).to eq([
        { type: :free_pizza },
        { type: :two_for_one }
      ])
    end

    it "ignores unknown promotion codes" do
      order = Order.new(
        promotion_codes: [ "INVALID", "FREE_PIZZA" ]
      )

      expect(order.promotions).to eq([
        { type: :free_pizza }
      ])
    end

    it "returns an empty array when no promotions are provided" do
      order = Order.new(promotion_codes: [])

      expect(order.promotions).to be_empty
    end

    it "returns an empty array when all codes are invalid" do
      order = Order.new(promotion_codes: [ "INVALID" ])

      expect(order.promotions).to be_empty
    end
  end
end
