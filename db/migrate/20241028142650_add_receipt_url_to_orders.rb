class AddReceiptUrlToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :receipt_url, :string
  end
end
