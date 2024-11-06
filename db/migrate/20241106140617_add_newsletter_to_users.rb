class AddNewsletterToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :newsletter, :boolean
  end
end
