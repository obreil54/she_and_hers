class AddFirstAndLastNameToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :first_name, :string
    add_column :orders, :last_name, :string
  end
end
