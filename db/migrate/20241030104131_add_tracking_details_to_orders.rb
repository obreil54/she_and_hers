class AddTrackingDetailsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :tracking_number, :string
    add_column :orders, :tracking_status, :string
  end
end
