
require "rails_helper"

RSpec.describe "Orders", type: :request do
  describe "GET /orders" do
    let!(:open_order) do
      Order.create!(uid: SecureRandom.uuid)
    end

    let!(:completed_order) do
      Order.create!(
        uid: SecureRandom.uuid,
        completed_at: 1.hour.ago
      )
    end

    it "returns HTTP success" do
      get orders_path

      expect(response).to have_http_status(:success)
    end

    it "displays only open orders" do
      get orders_path

      expect(response.body).to include(open_order.uid)
      expect(response.body).not_to include(completed_order.uid)
    end
  end

  describe "PATCH /orders/:id" do
    let!(:order) do
      Order.create!(uid: SecureRandom.uuid)
    end

    it "marks the order as completed" do
      expect {
        patch order_path(order)
      }.to change { order.reload.completed_at }.from(nil)

      expect(order.completed_at).to be_present
    end

    it "redirects to the orders index" do
      patch order_path(order)

      expect(response).to redirect_to(orders_path)
      expect(flash[:notice]).to eq("Order completed.")
    end

    it "returns 404 for a non-existent order" do
      patch order_path(id: 999_999)

      expect(response).to have_http_status(:not_found)
    end
  end
end
