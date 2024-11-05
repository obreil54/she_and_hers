class AddProviderAndServiceLevelToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :selected_provider, :string
    add_column :orders, :selected_service_level, :string
  end
end
