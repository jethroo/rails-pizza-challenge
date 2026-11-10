class OrdersController < ApplicationController
  before_action :set_order, only: %i[update]

  def index
    @orders = Order.open
  end

  def update
    @order.update!(completed_at: Time.current)

    redirect_to orders_path, notice: "Order completed."
  end

  private

  def set_order
    @order = Order.find(params.expect(:id))
  end
end
