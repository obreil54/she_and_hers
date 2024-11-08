class AddDiscountCodeToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :discount_code_id, :bigint
    add_foreign_key :orders, :discount_codes
  end
end
