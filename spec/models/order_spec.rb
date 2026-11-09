
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
end
