class DropProductsSizesTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :products_sizes
  end
end
