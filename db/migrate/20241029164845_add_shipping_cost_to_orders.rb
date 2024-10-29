class AddShippingCostToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :shipping_cost_cents, :integer
  end
end
