class RemoveDimensionsFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :length, :integer
    remove_column :products, :width, :integer
    remove_column :products, :height, :integer
  end
end
