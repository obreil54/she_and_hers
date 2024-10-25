class RemoveAddressFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :address_line1, :string
    remove_column :users, :address_line2, :string
    remove_column :users, :city, :string
    remove_column :users, :state, :string
    remove_column :users, :postal_code, :string
    remove_column :users, :country, :string
  end
end
