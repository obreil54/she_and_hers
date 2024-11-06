class CreateDiscountCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :discount_codes do |t|
      t.string :code, null: false
      t.integer :discount_percentage, null: false
      t.boolean :used, default: false, null: false

      t.timestamps
    end
  end
end
