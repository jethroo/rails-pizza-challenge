
require "rails_helper"

RSpec.describe OrderPricingService do
  subject(:service) { described_class.new(order) }

  let(:order) { Order.new(uid: SecureRandom.uuid) }
  let(:items) { [] }
  let(:promotions) { [] }
  let(:discount_multiplier) { BigDecimal("0") }

  before do
    allow(order).to receive(:order_items).and_return(items)
    allow(order).to receive(:promotions).and_return(promotions)
    allow(order).to receive(:discount_code_multiplier)
      .and_return(discount_multiplier)
  end

  def pizza(name:, size:, price:, extras: 0)
    instance_double(
      OrderItem,
      name: name,
      size: size,
      price: BigDecimal(price.to_s),
      extra_ingredients_price: BigDecimal(extras.to_s)
    )
  end

  describe "#call" do
    context "without promotions or discounts" do
      it "returns zero for an empty order" do
        expect(service.call).to eq(BigDecimal("0"))
      end

      it "calculates the price of a single pizza" do
        items << pizza(
          name: "Salami",
          size: "medium",
          price: "10.0"
        )

        expect(service.call).to eq(BigDecimal("10.0"))
      end

      it "sums multiple pizzas" do
        items << pizza(
          name: "Salami",
          size: "medium",
          price: "10.0"
        )
        items << pizza(
          name: "Margherita",
          size: "large",
          price: "12.0"
        )

        expect(service.call).to eq(BigDecimal("22.0"))
      end

      it "rounds the total to two decimal places" do
        items << pizza(
          name: "Salami",
          size: "small",
          price: "4.195"
        )

        expect(service.call).to eq(BigDecimal("4.20"))
      end
    end

    context "with promotions" do
      let(:promotions) do
        [
          {
            target: "Salami",
            target_size: "Medium",
            from: 3,
            to: 1
          }
        ]
      end

      it "makes one pizza free when buying three" do
        3.times do
          items << pizza(
            name: "Salami",
            size: "medium",
            price: "10.0"
          )
        end

        expect(service.call).to eq(BigDecimal("20.0"))
      end

      it "does not apply the promotion below the threshold" do
        2.times do
          items << pizza(
            name: "Salami",
            size: "medium",
            price: "10.0"
          )
        end

        expect(service.call).to eq(BigDecimal("20.0"))
      end

      it "applies the promotion to multiple groups" do
        6.times do
          items << pizza(
            name: "Salami",
            size: "medium",
            price: "10.0"
          )
        end

        expect(service.call).to eq(BigDecimal("40.0"))
      end

      it "ignores pizzas with a different size" do
        3.times do
          items << pizza(
            name: "Salami",
            size: "large",
            price: "15.0"
          )
        end

        expect(service.call).to eq(BigDecimal("45.0"))
      end

      it "ignores pizzas with a different name" do
        3.times do
          items << pizza(
            name: "Margherita",
            size: "medium",
            price: "8.0"
          )
        end

        expect(service.call).to eq(BigDecimal("24.0"))
      end

      it "charges extra ingredients on free pizzas" do
        3.times do
          items << pizza(
            name: "Salami",
            size: "medium",
            price: "12.0",
            extras: "2.0"
          )
        end

        # Two pizzas at 12, one pizza at 2
        expect(service.call).to eq(BigDecimal("26.0"))
      end
    end

    context "with a discount code" do
      let(:discount_multiplier) { BigDecimal("0.20") }

      it "applies the discount to the order total" do
        items << pizza(
          name: "Salami",
          size: "medium",
          price: "10.0"
        )

        expect(service.call).to eq(BigDecimal("8.0"))
      end

      it "applies the discount to multiple items" do
        items << pizza(
          name: "Salami",
          size: "medium",
          price: "10.0"
        )
        items << pizza(
          name: "Margherita",
          size: "large",
          price: "15.0"
        )

        expect(service.call).to eq(BigDecimal("20.0"))
      end
    end

    context "with promotions and a discount code" do
      let(:discount_multiplier) { BigDecimal("0.10") }
      let(:promotions) do
        [
          {
            target: "Salami",
            target_size: "Medium",
            from: 3,
            to: 1
          }
        ]
      end

      it "applies the discount after promotions" do
        3.times do
          items << pizza(
            name: "Salami",
            size: "medium",
            price: "10.0"
          )
        end

        # 30 - 10 promotion = 20
        # 20 - 10% discount = 18
        expect(service.call).to eq(BigDecimal("18.0"))
      end
    end
  end
end
