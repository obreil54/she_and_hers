class AddSizeToCartItems < ActiveRecord::Migration[7.1]
  def change
    add_column :cart_items, :size, :string
  end
end
