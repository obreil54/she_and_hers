class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.decimal :price
      t.text :description
      t.text :care_instructions

      t.timestamps
    end
  end
end
