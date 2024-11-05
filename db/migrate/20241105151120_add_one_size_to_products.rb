class AddOneSizeToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :one_size, :boolean, default: false, null: false
  end
end
