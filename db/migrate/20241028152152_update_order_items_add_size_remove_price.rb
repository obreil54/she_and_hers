class UpdateOrderItemsAddSizeRemovePrice < ActiveRecord::Migration[7.1]
  def change
    add_column :order_items, :size, :string
  end
end
