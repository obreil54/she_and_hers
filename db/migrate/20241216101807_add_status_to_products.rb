class AddStatusToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :status, :string, default: "available", null: false
  end
end
