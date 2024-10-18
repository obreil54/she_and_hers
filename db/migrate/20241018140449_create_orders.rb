class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :status
      t.monetize :total_amount, currency: { present: false }
      t.string :checkout_session_id
      t.references :user, foreign_key: true
      t.string :email
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.string :phone

      t.timestamps
    end
  end
end
