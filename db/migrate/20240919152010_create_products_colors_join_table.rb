class CreateProductsColorsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :products, :colors do |t|
      t.index :product_id
      t.index :color_id
    end
  end
end
