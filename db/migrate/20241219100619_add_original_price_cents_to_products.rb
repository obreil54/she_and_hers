class AddOriginalPriceCentsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :original_price_cents, :integer
  end
end
