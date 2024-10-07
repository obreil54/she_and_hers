class AddNameToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :name, :string
  end
end
